from setuptools import setup

setup(
    name = "terraform2ansible",
    version = "0.0.1",
    py_modules = ['parse_ips'],
    install_requires=[
        "Click",
        "pyparsing",
        "PyYAML"
    ],
    entry_points='''
        [console_scripts]
        terraform2ansible=parse_ips:cli
    '''
)

