# CustomKali
Simple Script to customize Kali Linux

## Step 1, User Initialization
Just after launching new Kali VM, execute this to create a new custom account
```
curl -fsSL https://github.com/Fropops/CustomKali/raw/refs/heads/main/InitUser.sh | sudo bash -s -- Fropops 'MonPassword'
```

##2 Step, after the Vm has restarted, logon with new created user and the execute the customze script : 
```
curl -fsSL https://github.com/Fropops/CustomKali/raw/refs/heads/main/CustomizeAndInstall.sh | bash
```