import torch

if __name__ == "__main__":
  if torch.cuda.is_available():
    for i in range(torch.cuda.device_count()):
      print(f"Device {i}: {torch.cuda.get_device_name(i)}")
  else:
    print("CUDA is not available.")