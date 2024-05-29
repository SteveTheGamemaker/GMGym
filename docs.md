# GameMaker: Studio 2 Gym Extension Documentation

## Important Note
To get started with this extension in your own project, you must delete the contents of the functions inside the 'game specific' scripts folder and replace them with your own appropriate code.

### oGym Object
This object manages the communication between GameMaker and a Python reinforcement learning environment (e.g., OpenAI Gym). You should put this in the room that has all your other objects in it. 

#### Create Event
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

#### Alarm 0 Event
This event triggers one step after creation and attempts to connect to the Python socket:
- Creates a client socket.
- Attempts to connect to the server using the provided IP and port.
- Sets `global.connected` to true upon successful connection.

#### Alarm 1 Event
This event triggers after the timeout duration (5 minutes) and ends the game if the client hasn't connected.

#### Async Networking Event
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

### "gym_" Scripts
These scripts handle the communication and synchronization between GameMaker and the Python environment.

#### gym_receive_actions()
This script receives a list of actions from the Python server:
- Reads the data from the asynchronous network buffer.
- Extracts the number of actions and the values of each action.
- Returns a DS list containing the received actions as floats.

#### gym_receive_reset()
This script receives the reset signal from the Python server:
- Reads a 32-bit integer from the asynchronous network buffer.
- If the integer is 1, calls `gym_reset()`.

#### gym_reset()
(Game Specific - Requires Modification)
This script handles resetting the game environment when instructed by the Python server. Replace the placeholder code with your game's specific reset logic.

#### gym_send_info()
This script sends the content of the `global.info_list` to the Python server:
- Creates a buffer and writes the list size and each element of the list as floats.
- Sends the buffer through the established network connection.

#### gym_send_observation()
This script sends a numeric observation list to the Python server:
- Creates a buffer, writing the list size and each element as floats.
- Sends the buffer through the network connection.
- Subsequently, calls `gym_send_info()` to send the `global.info_list`.

#### gym_send_screen()
This script captures the application surface, optionally resizes it, and sends it to the Python server:
- Creates a new surface based on the specified resolution.
- Copies the application surface to the new surface.
- Creates a buffer and copies the surface data into it.
- Sends the buffer size, width, height, and the image data through the network connection.
- Calls `gym_send_info()` after sending the image data.

#### gym_start()
(Game Specific - Requires Modification)
This script executes once at the beginning of the training process when the first action list is received. Replace the placeholder code with any initialization logic your game requires.

#### gym_step()
(Game Specific - Requires Modification)
This script is called every step and is responsible for updating your game objects' states. Replace the placeholder code with your game's update logic, ensuring all objects relevant to the reinforcement learning task are updated accordingly.

### Important Considerations
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
    * Utility function for creating multiple environments, with different seeds and startup delays.
* **Main Training Loop:**
    * Creates the training directory.
    * Initializes the vectorized environment (using multiple processes) and wraps it with `VecFrameStack` if needed.
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

# The Reward System for the Demo

## Overview

This document outlines the reward system employed in the GameMaker: Studio 2 Gym Extension demo project, focusing on how it motivates the AI agent to learn desired behaviors within the racing game environment. The demo features a car navigating a racetrack, with the goal of maximizing its cumulative reward by collecting checkpoints while staying on the track. 

## Reward Structure

The reward system is designed to encourage the agent to prioritize both speed and accuracy:

* **Checkpoint Collection:**  The primary source of positive reward is collecting checkpoints. Each successfully collected checkpoint grants a base reward of 0.5. 

* **Lap Completion Bonus:** To further incentivize progress, the agent receives an additional bonus that scales with the proportion of the lap completed. This bonus can reach up to 0.5, resulting in a maximum reward of 1 for collecting a checkpoint while completing a full lap. 

* **Off-Road Penalty:**  Straying off the track leads to a negative reward. The penalty is structured to mirror the reward for collecting checkpoints, discouraging the agent from taking shortcuts or driving recklessly. Going off-track results in a base penalty of -0.5, with an additional penalty of up to -0.5 proportional to the progress made in the current lap. Going off road also resets the environment.

* **Time-Based Penalty (Timeout):**  To prevent the agent from getting stuck or making minimal progress, a timeout mechanism is implemented. If the agent fails to collect a checkpoint within 500 steps, the episode ends with no reward, prompting the agent to explore more dynamic strategies.

## Reward Calculation

The total reward for each step is calculated as follows:

```python
reward = 0
timeout = 0

if new_checkpoint_collected:
    if on_road:
        reward = 0.5 + (current_checkpoints / total_checkpoints) / 2
        timeout = 0
else:
    timeout += 1

if off_road:
    reward = -(0.5 + (current_checkpoints / total_checkpoints) / 2)
    timeout = 0

if timeout >= 500:
    reward = 0 
    timeout = 0

final_reward = reward * 0.1
```

## Rationale

This reward structure, with its combination of positive and negative reinforcement, guides the agent towards learning a successful racing strategy. 

* **Balancing Speed and Accuracy:**  The scaling reward for checkpoint collection and lap completion encourages the agent to move quickly through the track. However, the substantial penalty for going off-road compels the agent to learn precise control and maintain a balance between speed and staying on the track.

* **Encouraging Exploration:**  The timeout penalty discourages passive or overly conservative behaviors.  It pushes the agent to explore different actions and strategies to avoid stagnation and find the optimal balance between exploration and exploitation.

## Machine Learning Context

In the context of reinforcement learning, this reward system serves as the primary feedback mechanism for the agent. The agent's goal is to learn a policy—a mapping from states to actions—that maximizes the expected cumulative reward it receives over time.

* **State Space:**  The agent's state can be represented by various observations, including its position on the track, speed, direction, and sensor readings that provide information about the track's layout. 

* **Action Space:**  Depending on the configuration (`actiontype`), the agent can have either a discrete action space (e.g., go forward, backward, turn left, turn right) or a continuous action space (e.g., steering speed/direction and acceleration).

* **Policy Optimization:**  The agent employs a reinforcement learning algorithm, such as Proximal Policy Optimization (PPO) in this demo, to learn an optimal policy. PPO iteratively updates the policy based on the rewards obtained from interacting with the environment. 

## Conclusion

The reward system, through its carefully designed structure, successfully guides the AI agent's learning process. It incentivizes the agent to master the racing task by finding an optimal balance between speed, accuracy, and exploration. This demo showcases how thoughtfully constructed reward systems are crucial for training effective reinforcement learning agents in simulated environments. 

# The Environment Layout and Mechanics of the RLCar Demo

## Overview

The RLCar demo environment presents a simulated racetrack where a car, controlled by an AI reinforcement learning(RL) agent, learns to navigate and collect rewards. This document delves into the intricate details of the environment's design and mechanics, emphasizing how they facilitate the learning process.

## Core Components

### 1. The Racetrack (oTrackEdge)

- **Role:**  Defines the boundaries of the racing environment. The car colliding with this object triggers the "off-road" penalty, as well as an environment reset, crucial for teaching the agent to stay on course. 

- **Implementation:**  This object is an object with a collision mask that accurately outlines the racetrack's edges.

### 2. The Car (oCar)

- **Role:** The agent's embodiment within the environment. Its movement and interactions with other objects determine the rewards received and the overall learning progress.

- **Key Variables:**
    - `controlmode`:  Determines whether the car is controlled by the "AI" or a "human" player.
    - `startx`, `starty`: Store the initial position for reset purposes.
    - `sensors`:  The number of distance sensors used for environment perception (default is 32).
    - `mySpeed`:  The car's current speed, influenced by acceleration, deceleration, and maximum speed limits.
    - `maxSpeed`:  The car's upper speed limit.
    - `acceleration`, `deceleration`: Control the rate of speed change.
    - `turnSpeed`:  Influences the car's turning radius based on its speed.
    - `moveDirection`: Represents the actual direction the car is moving in.
    - `move`: Indicates acceleration (1), deceleration (-1), or coasting (0).
    - `turn`:  Indicates the direction and degree of turning, with -1 for left and 1 for right.
    - `onRoad`: A boolean flag indicating whether the car is currently on the track (1) or off-track (0).
    - `maxsensordistance`: "The max sensor distance should be roughly the size of the longest line you could possibly travel on your track". This is used for normalization.
    - `checks`:  The number of checkpoints successfully collected.

- **Movement Mechanics:**
    - The car's movement is governed by a combination of acceleration, deceleration, and turning logic, simulating realistic driving dynamics.
    - The `image_angle` is adjusted based on the `turnSpeed` and the `turn` value, influencing the car's visual orientation on the track.

- **Sensor System:**
    - The car is equipped with multiple distance sensors (`oSensor` instances), each pointing outwards at regular intervals around its circumference.
    - These sensors measure the distance to the nearest `oTrackEdge` object, providing the agent with spatial awareness of its surroundings.

### 3. The Checkmarks (oCheck)

- **Role:**  Serve as reward points scattered along the racetrack. The agent's objective is to collect as many checkpoints as possible while maintaining a safe driving trajectory.

- **Implementation:**
    - Checkmarks are strategically placed along the racetrack, their position and orientation determined by the `oControl` object during the environment setup. Path1 is a manually made path along the track that facilitates the creation of these checkmarks.
    - They are only visible in the numeric observation mode to avoid cluttering the agent's vision in the visual observation mode, as well as the fact that in a numeric observation mode, the agent can also not 'see' the checkmarks.

- **Key Variables:**
    - `activated`:  A boolean flag indicating whether a checkpoint can be collected. Becomes true when the car is near and moving forward.
    - `index`: A unique identifier for each checkpoint, helpful for debugging and certain reset modes.

- **Reward Logic:**
    - A checkpoint is considered collected when the car collides with it while `activated` is false and the car is moving forward ( `oCar.mySpeed > 0` ).
    - This specific condition, "Only reward a checkpoint collected when going forward", prevents the agent from over-relying on reversing into checkpoints. 
    - Once collected, a checkpoint's `activated` flag is set to true, and its collision mask is disabled to prevent repeated collection.  An alarm is set to reactivate the checkpoint after a short period. 

## The control object (oControl)

- **Role:**  Manages the overall environment setup, including checkpoint placement, reset mechanics, and debug information display.

- **Key Variables:**
    - `global.maxchecks`:  Set maxchecks - I don't recommend putting this above 512.
    - `path_increment`:  Determines the spacing between checkpoints along the racetrack path.
    - `fixedpoint`:  Stores the checkpoint index used for the 'fixed' reset mode.
    - `resetmode`:  Determines the checkpoint selection logic upon reset. Options include 'randomnorepeat', 'randomgeneral', 'random', 'fixed', and 'optimized'.
    - `debuginfo`: A flag controlling the display of debug information.

- **Reset Modes:**
    - `randomnorepeat`:  Ensures the car starts at each checkpoint exactly once in a randomized order before repeating the cycle.
    - `randomgeneral`:  Randomly places the car at any valid point on the track, introducing more diverse starting scenarios.
    - `random`:  Randomly selects a checkpoint as the starting point.
    - `fixed`:  The car always starts at the same checkpoint, selected by the user with the mouse.
    - `optimized`: (Currently broken) Aims to prioritize checkpoints where the agent has historically collected fewer rewards.

## Interaction and Dynamics

The interplay between these core components—the racetrack, the car, and the checkpoints—forms the foundation of the RLCar demo's learning environment. The car, guided by its sensors and the chosen control mode, interacts with its surroundings.  Collecting checkpoints, staying on the track, and avoiding timeouts result in positive rewards that shape the AI agent's behavior, while negative rewards for going off-track or stalling encourage exploration and refinement of its driving strategy.

This documentation provides a comprehensive overview of the GameMaker Gym Extension. Remember to adapt the game-specific scripts to your project's needs.
