nixos-rebuild switch --target-host root@192.168.1.22 --flake .#marella --keep-going -j 7 --use-remote-sudo --impure --show-trace #--option substituters "" #--show-trace
#--keep-going #--build-host raspi
