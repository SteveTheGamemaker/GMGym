# GMGym
A Gamemaker extension that lets you use OpenAI Gym to make ML agents for your Gamemaker projects.

**This GameMaker extension bridges the gap between your GameMaker projects and the powerful OpenAI Gym reinforcement learning framework, opening the door to training intelligent agents that can interact with your game environments.** The extension simplifies the communication process, allowing you to focus on crafting engaging RL scenarios.

### Key Features:

- **Seamless Communication:** The extension establishes a robust connection between your GameMaker project and a Python server running OpenAI Gym, handling the exchange of information between them.

- **Versatile Observation Types:** Support for both visual and numeric observation spaces is included, letting your agents learn from different types of information, like screen snapshots (visual) or lists of numerical values (numeric).

- **Action Space Flexibility:** The extension accommodates both discrete and continuous action spaces, giving you the freedom to define how your agent interacts with the environment.

- **Demo Project:** A comprehensive demo project is provided to illustrate the extension's capabilities. It includes a simple racing game environment where you can observe an AI agent, trained in Python, controlling the car.

### Customization:

The demo showcases features like:

- **Reset Modes:** Choose from various starting positions for the car, including random, fixed, and optimized placements, to suit your training needs.

- **Action Control Schemes:** Utilize discrete actions for simple movements or continuous actions for more nuanced control.

- **Observation Types:** Experiment with visual or numeric observations to see how your agent learns best.

**With the power of GameMaker's intuitive development environment combined with OpenAI Gym's extensive libraries and algorithms, this extension unlocks a new realm of possibilities for creating and training RL agents within your game environments.**

### Important Note:

This extension is best suited for developers who are comfortable with reinforcement learning concepts, Python programming, and GameMaker Language (GML). A solid grasp of these technologies will enable you to fully harness the potential of the extension and build compelling RL environments within your GameMaker projects.

### Getting Started with the Demo:

To get started with the demo, follow these simple steps:

**Step 1: Preparation**

* Create a new folder on your computer named 'RLCar'.
* Ensure you have a Python version compatible with PyTorch (we recommend Python 3.8).
* Make sure you have all the required packages listed in the `requirements.txt` file(found in the included files once you import the asset in the next step).

**Step 2: Importing Assets**

* Create a new GameMaker project.
* Import all the objects from the RLCar folder in the github repo, including those found in the 'Demo' and 'OpenAI Gym' folders.
* Import `Path1`, `Room1`, all scripts, sprites, and the files from the 'Demo' included files folder.
* Alternatively, just open the RLCar.yyp file in the RLCar folder in the repo.

**Step 3: Organizing Files**

* Save your GameMaker project.
* Locate the 'Demo' included files folder and move the `gmgym` and `gmtrain` scripts into the 'RLCar' folder you created in Step 1.

**Step 4: Building and Placing the Executable**

* Build your GameMaker project.
* Move the resulting `RLCar.exe` file into the 'RLCar' folder alongside the `gmgym` and `gmtrain` scripts.

**Step 5: Configuring Training Parameters**

* Open the `gmtrain.py` script.
* Replace the placeholder IP address with your local IPv4 address.
* Specify the port number you want to use for the sockets.
* Choose between 'Visual' or 'Numeric' observation spaces.
* Select 'Continuous' or 'Discrete' action spaces.
* Adjust the number of parallel environments, frames to stack, and experiment with hyperparameters for the PPO model.
* Save the `gmtrain.py` file.

**Step 6: Starting Training**

* Open a Command Prompt (CMD).
* Navigate to the 'RLCar' folder using the `cd` command.
* Execute the following command to start training: `py -3.8 gmtrain.py`.

**Step 7: Interacting with the Environment**

* Observe the environment. You'll see the racing car moving around the track.
* Switch between AI control and manual control using the 'C' key.
* Toggle debug information with the 'F' key.
* Cycle through different reset modes using the 'R' key:
    * `randomnorepeat`: Randomly visits track points without repetition.
    * `randomgeneral`: Randomly visits any point on the track, including near walls.
    * `random`: Randomly visits points along the path.
    * `fixed`: Visits a specific point you can select with the mouse.
    * `optimized`: (Currently broken) Aims to visit points based on least reward collected.
* Toggle the visibility of checkpoints and sensor rays/targets with the 'D' key. 

Enjoy experimenting with this RL-powered car demo.
