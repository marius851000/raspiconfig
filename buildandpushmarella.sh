nixos-rebuild switch --target-host root@192.168.1.79 --flake .#marella --keep-going -j 7 --use-remote-sudo --impure --show-trace #-vvvv #--option substituters "" #--show-trace
#--keep-going #--build-host raspi
