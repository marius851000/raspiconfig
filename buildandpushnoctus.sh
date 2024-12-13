nixos-rebuild switch --target-host root@192.168.1.45 --flake .#noctus --keep-going -j 7 --use-remote-sudo --impure --show-trace #-vvvv #--option substituters "" #--show-trace
#--keep-going #--build-host raspi
