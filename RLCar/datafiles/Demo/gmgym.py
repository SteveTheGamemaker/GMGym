import gym
from gym import spaces
import cv2
import numpy as np
import random
import math
import socket
import struct
import time
import subprocess
import os

class GameEnv(gym.Env):
    metadata = {'render.modes': ['human']}

    def __init__(self, host, initial_port, max_attempts, observationtype, actiontype):
        super(GameEnv, self).__init__()
        self.observationtype=observationtype
        self.host = host
        self.port = initial_port
        self.max_attempts = max_attempts
        self.server_socket = None
        self.client_process = None
        self.client_socket = None
        self.connection_established = False
        self.checks = 0
        self.prev_checks = 0
        self.extravalue=0
        self.displaymode="all"
        self.action_list = [0, 0, 0, 0]
        self.actiontype = actiontype
        self.timeout = 0
        self.observationlength=38
        self.infolist = None
        self.render = True

        attempt = 0
        while attempt < self.max_attempts and not self.connection_established:
            try:
                self.start_server()
            except Exception as e:
                print(f"Failed to start server: {e}")
                attempt += 1
                continue

            print("Waiting for a connection...")
            self.attempt_connection()
            attempt += 1

        if not self.connection_established:
            raise Exception("Failed to establish connection after multiple attempts")

        if self.actiontype == "Discrete":
            self.action_space = spaces.Discrete(8)
        elif self.actiontype == "Continuous":
            self.action_space = spaces.Box(low=-1, high=1, shape=(2,), dtype=np.float32)

        if self.observationtype == "Visual":
            self.observation_space = spaces.Box(low=0, high=255, shape=(96, 96, 1), dtype=np.uint8) # You'll have to change this if you change the resolution parameter in gym_send_screen
        elif self.observationtype == "Numeric":
            self.observation_space = spaces.Box(low=-np.inf, high=np.inf, shape=(self.observationlength,), dtype=np.float32)

    def attempt_connection(self): 
        start_time = time.time()
        self.server_socket.settimeout(1)  # Set timeout for accepting connections

        try:
            self.client_socket, addr = self.server_socket.accept()
            print(f"Got a connection from {addr}")
            self.connection_established = True
        except socket.timeout:
            print("Connection attempt timed out. Retrying...")
            self.close_client()
            self.start_client(str(self.port))  # Retry starting the client if connection not established within timeout

        self.server_socket.settimeout(None)  # Remove timeout to revert to blocking mode

    def start_server(self):
        self.server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)

        try:
            self.server_socket.bind((self.host, self.port))
            self.server_socket.listen(18)
            print(f"Server is listening on port {self.port}")
            self.start_client(str(self.port))
        except OSError as e:
            raise Exception(f"Failed to start server on port {self.port}: {e}")

    def start_client(self, port):
        executable_path = 'RLCar.exe'
        
        # Convert port number to string if it's not already
        port_str = str(port)
        
        # Format the command as a string if shell=True
        command = f"{executable_path} {self.host} {port_str} {self.observationtype} {self.actiontype} {self.displaymode}"
        
        # Use subprocess.Popen for asynchronous execution
        try:
            self.client_process = subprocess.Popen(command)
        except Exception as e:
            print(f"Failed to start client process: {e}")
        
    def is_connected(self):
        return self.connection_established

    def send_actions(self, client_socket, actions, debug=False):
        try:
            data_to_send = struct.pack('I', len(actions))  # Pack the length of the actions list
            for number in actions:
                # Pack each number as a 32-bit float
                data_to_send += struct.pack('f', number)
            
            # Optional debug line to print the action list before sending
            if debug:
                print(f"Sending actions: {actions}")
            
            client_socket.send(data_to_send)
            time.sleep(0.01)
        except (ConnectionResetError, BrokenPipeError):
            print("Client disconnected.")
            return False
        return True
        
    def send_reset(self, client_socket, reset_state):
        try:
            #print(f"Sending reset state to the client: {reset_state}")
            data_to_send = struct.pack('i', reset_state)
            client_socket.send(data_to_send)
            time.sleep(0.01)
        except (ConnectionResetError, BrokenPipeError):
            print("Client disconnected.")
            return False
        return True
        
    def get_info(self, client_socket):
        try:
            data_received = client_socket.recv(4)
            if not data_received:
                print("Client may have disconnected.")
                return None
            list_size = struct.unpack('I', data_received)[0]
            numbers = []
            for _ in range(list_size):
                float_bytes = b''
                while len(float_bytes) < 4:
                    fragment = client_socket.recv(4 - len(float_bytes))
                    if not fragment:
                        print("Connection interrupted during data reception.")
                        return None
                    float_bytes += fragment
                number = struct.unpack('f', float_bytes)[0]
                numbers.append(number)
            # Uncomment the line below for debugging
            # print(f"Received information list from the client: {numbers}")
            self.infolist = np.array(numbers, dtype=np.float32)
        except (ConnectionResetError, BrokenPipeError):
            print("Connection lost with the client.")
            return None

    def get_observation(self, client_socket):   
        try:
            data_received = client_socket.recv(4)
            if not data_received:
                print("Client may have disconnected.")
                return None

            list_size = struct.unpack('I', data_received)[0]
            numbers = []
            for _ in range(list_size):
                float_bytes = b''
                while len(float_bytes) < 4:
                    fragment = client_socket.recv(4 - len(float_bytes))
                    if not fragment:
                        print("Connection interrupted during data reception.")
                        return None
                    float_bytes += fragment
                number = struct.unpack('f', float_bytes)[0]
                numbers.append(number)
            # Uncomment the line below for debugging
            # print(f"Received observation list from the client: {numbers}")
            observation = np.array(numbers, dtype=np.float32)
            self.get_info(client_socket)
            return observation
        except (ConnectionResetError, BrokenPipeError):
            print("Connection lost with the client.")
            return None
            
    def get_screen(self, client_socket):
        try:
            # Receive the header first (12 bytes: 4 for size, 4 for width, 4 for height)
            header = client_socket.recv(12)
            if not header:
                print("Client may have disconnected.")
                return None

            # Unpack the header to get buffer size, width, and height
            buffer_size, width, height = struct.unpack('III', header)

            # Now receive the actual image buffer based on the received size
            img_data = b''
            while len(img_data) < buffer_size:
                packet = client_socket.recv(min(4096, buffer_size - len(img_data)))
                if not packet:
                    print("Connection interrupted during image data reception.")
                    return None
                img_data += packet

            # Convert the received image data to a NumPy array
            img_array = np.frombuffer(img_data, dtype=np.uint8).reshape((height, width, 4))

            # Convert from RGBA to grayscale
            buffer_gray = cv2.cvtColor(img_array, cv2.COLOR_RGBA2GRAY)

            # Expand dimensions to maintain the shape as (height, width, 1)
            buffer_gray = np.expand_dims(buffer_gray, axis=-1)

            if self.render and self.port == 8888:
                cv2.imshow('Grayscale Image', buffer_gray)
                cv2.waitKey(1)

            # Receive the info list
            self.get_info(client_socket)

            return buffer_gray

        except (ConnectionResetError, BrokenPipeError) as e:
            print(f"Connection lost with the client: {str(e)}")
            return None
        except Exception as e:
            print(f"An error occurred: {str(e)}")
            return None

    def close_client(self):
        if self.client_process is not None:
            try:
                self.client_process.terminate()
                self.client_process.wait()
                print("Client process terminated.")
            except Exception as e:
                print(f"Failed to terminate client process: {e}")
            finally:
                self.client_process = None

    def step(self, action):
        try:
            reward=0
            done = False
            
            self.prev_checks = self.checks
            
            self.checks = self.infolist[0] # Get number of checkpoints collected from the game
            onroad = self.infolist[1] # Get the on road status from the game
            maxchecks = self.infolist[2] # Get the maximum number of checkpoints from the game
            
            if self.actiontype == "Discrete":
                if action == 0:  # Go forward
                    self.action_list[1] = 0 # Cant go backwards while you're going forwards
                    self.action_list[0] = 1
                elif action == 1:  # Stop going forward
                    self.action_list[0] = 0 # Set this AND the below variable to 0 to enable stopping
                elif action == 2:  # Go backwards
                    self.action_list[0] = 0 # Can't go forwards while you're going backwards(Set this to 0 to enable stopping and going backwards)
                    self.action_list[1] = 1 # Set this to 1 to enable going backwards
                elif action == 3:  # Stop going backwards
                    self.action_list[1] = 0
                elif action == 4:  # Turn right
                    self.action_list[3] = 0 # Cant turn left while you're turning right
                    self.action_list[2] = 1
                elif action == 5:  # Stop Turning right
                    self.action_list[2] = 0
                elif action == 6:  # Turn left
                    self.action_list[2] = 0 # Cant turn right while you're turning left
                    self.action_list[3] = 1
                elif action == 7:  # Stop Turning left
                    self.action_list[3] = 0
            elif self.actiontype == "Continuous":
                self.action_list[0] = action[0]
                self.action_list[1] = action[1]

            # Sending actions to the game
            if not self.send_actions(self.client_socket, self.action_list):
                print("Failed to send actions. Ending episode.")
                return None, 0, True, {}  # Observation, reward, done, info

            # Get observation from game
            if self.observationtype == "Visual":
                observation = self.get_screen(self.client_socket)
            elif self.observationtype == "Numeric":
                observation = self.get_observation(self.client_socket)
            
            if observation is None:
                print("Failed to get observation. Ending episode.")
                return None, 0, True, {}  # Observation, reward, done, info

            # Calculate reward
            if self.checks > self.prev_checks: # If you've gained a checkpoint
                if onroad == 1:
                    reward = 0.5 + ((self.checks / maxchecks)/2) # More reward for more checks (0.5 base reward + up to 0.5 reward per lap completed)
                    self.timeout = 0
                    # print("Got checkpoint")
            else:
                reward = 0
                self.timeout += 1
                
            if onroad == 0:
                reward = -(0.5 + ((self.checks / maxchecks)/2)) # Balance the penalty with the reward
                done = True
                self.timeout = 0

            if self.timeout >= 500:
                done = True
                self.timeout = 0

            reward = reward*0.1

            info = {}  # Additional info, if any (Different info than 'information')
            
            # Process final observation for this step because of a weird extra 0
            if self.observationtype == "Numeric":
                final_observation = observation[:self.observationlength] # For some reason there is an extra 0 at the end of the observation list that I couldn't seem to iron out so. We're just obliterating it here for now
                # print("Final numeric observation: " + str(final_observation)) # Debug to show the final observation list
            elif self.observationtype == "Visual":
                final_observation = observation
                # print("Final visual observation: " + str(final_observation)) # Debug to show the final visual observation in array form

            return final_observation, reward, done, info
        except Exception as e:
            print(f"An error occurred during step execution: {e}")

    def reset(self):
        try:
            self.send_reset(self.client_socket, 1)
            if self.observationtype == "Visual":
                reset_observation = self.get_screen(self.client_socket)
            elif self.observationtype == "Numeric":
                reset_observation = self.get_observation(self.client_socket)
            
            if reset_observation is None:
                print("Failed to get reset observation. Restarting episode.")
                return self.reset()  # Attempt to reset again

            if self.observationtype == "Numeric":
                final_observation = reset_observation[:self.observationlength]
            elif self.observationtype == "Visual":
                final_observation = reset_observation
            return final_observation
        except Exception as e:
            print(f"An error occurred during reset: {e}")

    def render(self):
        if self.observationtype == "Visual":
            self.render = True # This will enable the code in get_screen that shows what the AI sees in an OpenCV window.

    def close(self):
        try:
            self.close_client()
            self.server_socket.close()
        except Exception as e:
            print(f"An error occurred during close: {e}")