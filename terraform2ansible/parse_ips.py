from pyparsing import Suppress, Word, Combine, Group, nums, ZeroOrMore
from functools import partial
import yaml
import click
click.option = partial(click.option, show_default=True)

def create_ip_parser(group_name):
    LBRACE, RBRACE, EQ, COMMA = map(Suppress, "[]=,")
    _group_ips = Suppress(group_name)
    integer = Word(nums)
    ipAddress = Combine(integer + "." + integer + "." + integer + "." + integer)
    ipList = Group(ipAddress + ZeroOrMore(COMMA + ipAddress))

    group_ips = _group_ips + EQ + LBRACE + ipList('ips') + RBRACE
    return group_ips

def create_yaml_inventory():
    return {'all':{'children':{}}}

def update_yaml_inventory(inventory, ip_parser, sample, group_name, label,
        user, variables=None):
    for item, _, _ in ip_parser.scanString(sample):
        l_id = 0
        inventory['all']['children'][group_name] = {}
        inventory['all']['children'][group_name]['hosts'] = {}
        for ip in item.ips:
            inventory['all']['children'][group_name]['hosts'][label + str(l_id)] = (
                    {'ansible_ssh_host': ip, 'ansible_ssh_user': user}
            )
            l_id += 1
    return inventory

def update_inventory_variables(inventory, group_name, variables):
    inventory['all']['children'][group_name]['vars'] = variables
    return inventory

def get_ip_from_group_name(inventory, group_name, label, index):
    if ( group_name in inventory['all']['children'] and
        label + str(index) in inventory['all']['children'][group_name]['hosts'] ):
        return (inventory['all']
                ['children']
                [group_name]
                ['hosts']
                [label + str(index)]
                ['ansible_ssh_host'])

@click.command()
@click.option('--tf_client_ips', default='clients_public_ips',
        help='The terraform group name for client public ips')
@click.option('--client_group_name', default='clients',
        help='The ansible group name for clients')
@click.option('--client_label', default='client',
        help='The label for each machine in --client_group_name')
@click.option('--server_label', default='server',
        help='The label for each machine in --server_group_name')
@click.option('--client_user', default='ubuntu',
        help='The username for each machine in --client_group_name')
@click.option('--server_user', default='ubuntu',
        help='The username for each machine in --server_group_name')
@click.option('--tf_server_ip', default='server_public_ip',
        help='The terraform group name for server public ip')
@click.option('--server_group_name', default='servers',
        help='The ansible group name for servers')
@click.option('--tf_buildbarn_labels', nargs=4,
        default=('bbb_frontends_public_ip',
            'bbb_schedulers_public_ip',
            'bbb_storage_public_ip',
            'bbb_workers_public_ip'),
        help='The terraform labels for buildbarn server components')
@click.option('--buildbarn_group_names', nargs=4,
        default=('bbb-frontend',
            'bbb-scheduler',
            'bbb-storage',
            'bbb-workers'),
        help='The ansible group names for buildbarns server components')
@click.option('--buildbarn_labels', nargs=4,
        default=('bbb_frontend',
            'bbb_scheduler',
            'bbb_storage',
            'bbb_workers'),
        help='The buildbarn labels for each component in --buildbarn_group_names')
@click.option('--buildbarn_config', nargs=3,
        default=('bbb_scheduler_addr',
            'bbb_cas_addr',
            'bbb_ac_addr'),
        help='ansible variables for bbb_modules: scheduler, cas and ac addresses respectively')
@click.option('--re_client_config', nargs=1,
        default=('bazel_re_addr'),
        help='ansible variables for remote exec clients: atm this is the ip for the remote executor')
@click.option('--out', type=click.File('w'), default='-',
        help='Outputs to a file if specifed, stdout if not')
def cli(tf_client_ips, tf_server_ip, client_group_name, server_group_name,
        client_label, server_label, client_user, server_user,
        tf_buildbarn_labels, buildbarn_group_names,
        buildbarn_labels, buildbarn_config, re_client_config,
        out, client_variables=None):
    tf_input = click.get_text_stream('stdin').read()

    public_ips_parser = create_ip_parser(tf_client_ips)

    inventory = create_yaml_inventory()
    inventory = update_yaml_inventory(inventory, public_ips_parser, tf_input,
            client_group_name, client_label, client_user)

    buildbarn_ips = {}
    buildbarn_ans_vars = {}
    client_ans_vars = {}
    scheduler_ans_var = buildbarn_config[0]
    cas_ans_var = buildbarn_config[1]
    ac_ans_var = buildbarn_config[2]

    re_addr_ans_var = re_client_config

    frontend_ans_group = buildbarn_group_names[0]
    sched_ans_group = buildbarn_group_names[1]
    storage_ans_group = buildbarn_group_names[2]
    worker_ans_group = buildbarn_group_names[3]

    buildbarn_mapping = zip(tf_buildbarn_labels, 
            buildbarn_group_names,
            buildbarn_labels)
    for tf_label, ans_group, ans_label in buildbarn_mapping:
        server_ip_parser = create_ip_parser(tf_label)
        inventory = update_yaml_inventory(inventory, server_ip_parser, tf_input,
                ans_group, ans_label, server_user)
        buildbarn_ips[ans_group] = get_ip_from_group_name(inventory, 
                                                    ans_group,
                                                    ans_label,
                                                    0)
    if sched_ans_group in buildbarn_ips:
        buildbarn_ans_vars[scheduler_ans_var] = buildbarn_ips[sched_ans_group]
    if storage_ans_group in buildbarn_ips:
        buildbarn_ans_vars[cas_ans_var] = buildbarn_ips[storage_ans_group]
        buildbarn_ans_vars[ac_ans_var] = buildbarn_ips[storage_ans_group]
    if frontend_ans_group in buildbarn_ips:
        client_ans_vars[re_addr_ans_var] = buildbarn_ips[frontend_ans_group]
    update_inventory_variables(inventory, 
            frontend_ans_group,
            buildbarn_ans_vars)
    update_inventory_variables(inventory, 
            worker_ans_group,
            buildbarn_ans_vars)
    update_inventory_variables(inventory, 
            client_group_name,
            client_ans_vars)

    click.echo(yaml.dump(inventory, default_flow_style=False), file=out)
