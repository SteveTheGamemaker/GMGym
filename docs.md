# GameMaker: Studio 2 Gym Extension Documentation

## Important Note
To get started with this extension in your own project, you must delete the contents of the functions inside the 'game specific' scripts folder and replace them with your own appropriate code.

### 1. oGym Object
This object manages the communication between GameMaker and a Python reinforcement learning environment (e.g., OpenAI Gym). You should put this in the room that has all your other objects in it. 

#### 1.1. Create Event
This event initializes variables and establishes the connection with the Python server.
- **Variables:**
  - `global.action_list`: A DS list to store actions received from the Python server.
  - `global.observation_list`: A DS list to store the numeric observation to be sent to the Python server.
  - `global.info_list`: A DS list to store additional information to be sent alongside the observation.
  - `global.connected`: A boolean indicating whether the connection with the Python server is established.
  - `global.port`: An integer representing the port number for communication.
  - `global.ip`: A string representing the IP address of the Python server.
  - `global.started`: A boolean indicating whether the training process has started.
  - `global.actiontype`: A string, either "Discrete" or "Continuous", specifying the type of actions used.
  - `observationtype`: A string, either "Visual" or "Numeric", specifying the type of observation used.
  - `displayMode`: A string, either "all", "first", or "none", controlling the rendering of parallel environments.
  - `autoalign`: A boolean controlling whether to automatically align the windows of parallel environments.
- **Socket Initialization:**
  - Sets a timeout alarm for 5 minutes.
  - Attempts to retrieve parameters passed from the Python script (IP, port, observation type, action type, display mode).
  - Handles display mode settings based on the chosen observation type.
  - If autoalign is true, positions the game window on the screen based on its port number.
  - Creates a TCP socket and attempts to connect to the specified IP and port.

#### 1.2. Alarm 0 Event
This event triggers one step after creation and attempts to connect to the Python socket:
- Creates a client socket.
- Attempts to connect to the server using the provided IP and port.
- Sets `global.connected` to true upon successful connection.

#### 1.3. Alarm 1 Event
This event triggers after the timeout duration (5 minutes) and ends the game if the client hasn't connected.

#### 1.4. Async Networking Event
This event handles communication with the Python server:
- **Receiving Reset Signal:** Calls `gym_receive_reset()` to handle the reset signal from the server.
- **First Action Packet:**
  - Sets `global.started` to true.
  - Calls `gym_start()`.
- **Receiving Actions:**
  - Calls `gym_receive_actions()` to update `global.action_list` with the received actions.
  - If `global.action_list` is not empty, calls `gym_step()`.
- **Sending Observation:**
  - If `observationtype` is "Visual", calls `gym_send_screen(0)` to send the application surface.
  - If `observationtype` is "Numeric", calls `gym_send_observation(global.observation_list)` to send the numeric observation list.

### 2. "gym_" Scripts
These scripts handle the communication and synchronization between GameMaker and the Python environment.

#### 2.1. gym_receive_actions()
This script receives a list of actions from the Python server:
- Reads the data from the asynchronous network buffer.
- Extracts the number of actions and the values of each action.
- Returns a DS list containing the received actions as floats.

#### 2.2. gym_receive_reset()
This script receives the reset signal from the Python server:
- Reads a 32-bit integer from the asynchronous network buffer.
- If the integer is 1, calls `gym_reset()`.

#### 2.3. gym_reset()
(Game Specific - Requires Modification)
This script handles resetting the game environment when instructed by the Python server. Replace the placeholder code with your game's specific reset logic.

#### 2.4. gym_send_info()
This script sends the content of the `global.info_list` to the Python server:
- Creates a buffer and writes the list size and each element of the list as floats.
- Sends the buffer through the established network connection.

#### 2.5. gym_send_observation()
This script sends a numeric observation list to the Python server:
- Creates a buffer, writing the list size and each element as floats.
- Sends the buffer through the network connection.
- Subsequently, calls `gym_send_info()` to send the `global.info_list`.

#### 2.6. gym_send_screen()
This script captures the application surface, optionally resizes it, and sends it to the Python server:
- Creates a new surface based on the specified resolution.
- Copies the application surface to the new surface.
- Creates a buffer and copies the surface data into it.
- Sends the buffer size, width, height, and the image data through the network connection.
- Calls `gym_send_info()` after sending the image data.

#### 2.7. gym_start()
(Game Specific - Requires Modification)
This script executes once at the beginning of the training process when the first action list is received. Replace the placeholder code with any initialization logic your game requires.

#### 2.8. gym_step()
(Game Specific - Requires Modification)
This script is called every step and is responsible for updating your game objects' states. Replace the placeholder code with your game's update logic, ensuring all objects relevant to the reinforcement learning task are updated accordingly.

### 3. Important Considerations
- **Game Specific Code:** The `gym_reset()` and `gym_step()` scripts are placeholders from the RLCar demo and require modification to match your specific game logic.
- **Network Communication:** This documentation assumes basic familiarity with GameMaker's networking functions. Consult the GameMaker documentation for further details on network communication.
- **Performance:** Sending visual observations can be resource-intensive, especially at higher resolutions. Choose a suitable resolution and consider performance implications when using visual observations.



## gmgym.py and gmtrain.py

These two Python scripts are designed to work with the GameMaker: Studio 2 Gym Extension, facilitating the training of reinforcement learning agents within GameMaker environments using OpenAI Gym.

### gmgym.py

This script defines the `GameEnv` class, which acts as a bridge between your GameMaker game and the OpenAI Gym environment. 

#### Key Components:

* **`__init__(self, host, initial_port, max_attempts, observationtype, actiontype)`:**
    * Initializes the environment, attempting to establish a connection with the GameMaker game.
    * Parameters:
        * `host`: The IP address of the machine running the GameMaker game.
        * `initial_port`: The starting port for communication.
        * `max_attempts`: The maximum number of connection attempts.
        * `observationtype`: The type of observation space ("Visual" or "Numeric").
        * `actiontype`: The type of action space ("Discrete" or "Continuous").
* **`attempt_connection(self)`:**  
    * Attempts to establish a connection with the GameMaker game on the specified port.
    * Starts the client process if the connection hasn't been established within the timeout.
* **`start_server(self)`:** 
    * Creates and binds a server socket on the specified host and port.
    * Starts the client process.
* **`start_client(self, port)`:** 
    * Starts the GameMaker game executable with appropriate parameters (host, port, observation type, action type, display mode).
* **`is_connected(self)`:**  
    * Checks if the connection with the GameMaker game is established.
* **`send_actions(self, client_socket, actions)`:** 
    * Sends the chosen actions to the GameMaker game through the socket.
* **`send_reset(self, client_socket, reset_state)`:** 
    * Sends a reset signal to the GameMaker game.
* **`get_info(self, client_socket)`:** 
    * Receives additional information from the GameMaker game (defined in the `global.info_list`).
* **`get_observation(self, client_socket)`:**
    * Receives the observation data (either a numeric list or a visual frame) from the GameMaker game.
* **`get_screen(self, client_socket)`:** 
    * Specifically receives and processes visual observation data (a screenshot of the game).
* **`close_client(self)`:**  
    * Terminates the client process (the running GameMaker game).

#### Gym Environment Methods:

* **`step(self, action)`:**
    * Executes a single step in the environment.
    * Sends the chosen action to the GameMaker game.
    * Receives and returns the observation, reward, done flag, and additional information.
* **`reset(self)`:**
    * Resets the GameMaker game environment and returns the initial observation.
* **`render(self)`:**
    * Renders the environment (if visual observation is used).
* **`close(self)`:**
    * Closes the environment and terminates the connection.


### gmtrain.py

This script sets up the training process for your reinforcement learning agent. It uses the `GameEnv` class defined in `gmgym.py` to interact with the GameMaker game.

#### Key Components:

* **Environment Configuration:**
    * Sets `observation_type`, `IP`, `firstport`, and `action_type` based on your environment and network setup.
* **Device Selection:**
    * Checks for CUDA availability and selects the appropriate device ("cuda" for GPU, "cpu" otherwise).
* **`SaveOnBestTrainingRewardCallback` Class:**
    * Defines a custom callback to save the best model based on training reward.
* **`make_env(rank, seed=0, delay=1.0)` Function:**
    * Utility function for creating multiple environments, potentially with different seeds and startup delays.
* **Main Training Loop:**
    * Creates the training directory.
    * Initializes the vectorized environment (potentially using multiple processes) and wraps it with `VecFrameStack` if needed.
    * Selects the appropriate policy network architecture (`CnnPolicy` for visual observations, `MlpPolicy` for numeric observations) based on the chosen observation type.
    * Instantiates the PPO agent with specified hyperparameters.
    * Sets up the `SaveOnBestTrainingRewardCallback`.
    * Starts the training process using `model.learn()`.
    * Saves the trained model.


### How to Use:

1. **Configure `gmgym.py`:** Adjust the action and observation spaces, network settings, and ensure the client executable path is correct.
2. **Configure `gmtrain.py`:** Set the environment parameters, network settings, and training hyperparameters.
3. **GameMaker Project:**
    * Implement the `gym_reset()`, `gym_start()`, and `gym_step()` scripts in your GameMaker project to handle environment logic.
    * Set up the communication with the Python server using the provided GameMaker Gym Extension.
4. **Run Training:** Execute `gmtrain.py` to start the training process.

This setup allows you to leverage the power of OpenAI Gym and reinforcement learning to train intelligent agents that can interact with your GameMaker games.

This documentation provides a comprehensive overview of the GameMaker Gym Extension. Remember to adapt the game-specific scripts to your project's needs.
