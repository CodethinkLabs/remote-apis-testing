Converts terraform output to a ansible hosts file

## Requires
- pyparsing
- configparser
- Click

## Install

- It is recommended to setup a virtualenv.
```
cd terraform2ansible
pip3 install .
```

## Usage
```
cat [INPUT_FILE] | terraform2ansible
```

You can then use the `hosts` file with `ansible-playbook`:

```
ansible-playbook -i hosts ansible/<PLAYBOOK> --ask-vault-pass
```


See `terraform2ansible --help` for more details
