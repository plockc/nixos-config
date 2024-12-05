Download nixos iso to disk, burn with rufus in windows, dd in linux or OS X

Install to disk, reboot and login

Update environment.systepmPackages with vim

Uncomment services.openssh.enable = true
Update hostname

```
sudo nixos-rebuild switch
sudo systemctl reboot
```

Back on the existing host
```
ssh-copy-id lenovo
```

ssh into lenovo and do the rest on that box
```
sudo su -
ssh-keygen -t ed25519
```

log into github.com, click on your profile pic, settings, ssh and GPG keys, add ssh key
confirm fingerprint https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/githubs-ssh-key-fingerprints
```
EMAIL="you@example.com"
NAME="your name"
mkdir tmp
cd tmp
git clone git@github.com:plockc/nixos-config.git
sudo mv nixos-config/* nixos-config/.git* /etc/nixos
cd ..
rmdir nixos-config
sudo chown root /etc/nixos/* # will leave .git alone
# git config --global --add safe.directory /etc/nixos
git config --global user.email "$EMAIL"
git config --global user.name "$NAME"
```

