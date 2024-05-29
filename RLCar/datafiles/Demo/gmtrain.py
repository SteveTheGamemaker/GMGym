import gym
import numpy as np
import os
import torch
import time
from stable_baselines3 import PPO
from stable_baselines3.common.vec_env import DummyVecEnv, VecMonitor
from stable_baselines3.common.monitor import Monitor
from stable_baselines3.common.callbacks import BaseCallback
from stable_baselines3.common.results_plotter import load_results, ts2xy
from stable_baselines3.common.utils import set_random_seed
from stable_baselines3.common.vec_env import VecFrameStack
from stable_baselines3.common.vec_env import SubprocVecEnv

observation_type = "Numeric" # Set the observation type (This will be passed through to both the python server and the gamemaker instance)
IP = "" # Replace this with your IP
firstport = 8888 # The starting port. Multiple environments will start on this port and climb from there.
action_type = "Continuous"

# Check if CUDA is available
if torch.cuda.is_available():
    print("CUDA is available. Using GPU.")
    device = "cuda"
else:
    print("CUDA not available. Using CPU.")
    device = "cpu"

from gmgym import GameEnv  # Your custom environment import

class SaveOnBestTrainingRewardCallback(BaseCallback):
    """
    Callback for saving the best model based on training reward.
    """
    def __init__(self, check_freq: int, log_dir: str, verbose: int = 1):
        super().__init__(verbose)
        self.check_freq = check_freq
        self.log_dir = log_dir
        self.save_path = os.path.join(log_dir, 'best_model')
        self.best_mean_reward = -np.inf

    def _init_callback(self) -> None:
        try:
            if self.save_path is not None:
                os.makedirs(self.save_path, exist_ok=True)
        except Exception as e:
            print(f"Error creating directory {self.save_path}: {e}")

    def _on_step(self) -> bool:
        try:
            if self.n_calls % self.check_freq == 0:
                x, y = ts2xy(load_results(self.log_dir), 'timesteps')
                if len(x) > 0:
                    mean_reward = np.mean(y[-100:])
                    if self.verbose > 0:
                        print(f"Num timesteps: {self.num_timesteps}")
                        print(f"Best mean reward: {self.best_mean_reward:.2f} - Last mean reward: {mean_reward:.2f}")
                    if mean_reward > self.best_mean_reward:
                        self.best_mean_reward = mean_reward
                        if self.verbose > 0:
                            print(f"Saving new best model to {self.save_path}")
                        self.model.save(self.save_path)
            return True
        except Exception as e:
            print(f"Error during callback step: {e}")
            return False

def make_env(rank, seed=0, delay=1.0):
    """
    Utility function for multiprocessed env with a delay before starting each subprocess.
    :param rank: Unique identifier for each process.
    :param seed: Random seed for the environment.
    :param delay: Time in seconds to wait before starting the process.
    """
    
    def _init():
        try:
            time.sleep(rank * delay)  # Delay each process based on its rank
            env = GameEnv(host=IP, initial_port=firstport + rank, max_attempts=5, observationtype=observation_type, actiontype=action_type)  # Adjust port to avoid conflicts
            env.seed(seed + rank)
            return env
        except Exception as e:
            print(f"Error creating environment for rank {rank}: {e}")
            return None
    set_random_seed(seed)
    return _init

if __name__ == '__main__':
    try:
        log_dir = "training_logs/"
        os.makedirs(log_dir, exist_ok=True)

        num_cpu = 4 # Number of processes to use
        # Create the vectorized environment as before
        env = VecMonitor(SubprocVecEnv([make_env(i) for i in range(num_cpu)]), log_dir)
        # Now wrap it with VecFrameStack to stack 4 frames
        env = VecFrameStack(env, n_stack=4)

        if observation_type == "Visual":
            model = PPO('CnnPolicy', env, verbose=1, tensorboard_log="./ppo_tensorboard/", learning_rate=0.00013, device=device)
        elif observation_type == "Numeric":
            model = PPO('MlpPolicy', env, verbose=1, tensorboard_log="./ppo_tensorboard/", learning_rate=0.0028, device=device)
        callback = SaveOnBestTrainingRewardCallback(check_freq=1000, log_dir=log_dir)
        model.learn(total_timesteps=int(100000000), callback=callback)  # Adjust the number of timesteps as needed

        model.save("RLCar_ppo_model")
        print("Training complete.")
    except Exception as e:
        print(f"Error during training: {e}")

