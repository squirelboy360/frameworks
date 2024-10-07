#!/bin/bash

# Create the Direct Native (DN) framework project
create_dn_project() {
    PROJECT_NAME="direct_native"
    
    # Create the project using Dart
    dart create -t package $PROJECT_NAME
    cd $PROJECT_NAME

    # Create directory structure
    mkdir -p bin lib/src/{core/{native_bridge,rendering,state_management},ui/{primitives,layout,advanced},navigation,styling,data/{network,storage},performance,testing,build,plugins,cli/commands} example/todo_app/lib docs/{api,guides} tools

    # Create initial files
    touch bin/dn.dart
    touch lib/src/cli/{cli_runner.dart,commands/{create_command.dart,run_command.dart}}
    touch lib/src/core/{native_bridge/method_channel.dart,rendering/{engine.dart,virtual_dom.dart},state_management/store.dart}
    touch lib/src/ui/{primitives/{text.dart,button.dart,image.dart},layout/{stack.dart,row.dart,column.dart},advanced/{list_view.dart,modal.dart}}
    touch lib/src/navigation/{stack.dart,router.dart,tab_controller.dart}
    touch lib/src/styling/{style_system.dart,theme.dart,animations.dart}
    touch lib/src/data/{network/http_client.dart,storage/key_value_store.dart}
    touch lib/src/performance/{optimizer.dart,background_task.dart}
    touch lib/src/testing/{test_framework.dart,mock_native.dart}
    touch lib/src/build/compiler.dart
    touch lib/src/plugins/plugin_manager.dart
    touch example/todo_app/{lib/main.dart,pubspec.yaml}
    touch tools/code_generator.dart
    touch CONTRIBUTING.md

    # Update pubspec.yaml
    cat << EOF > pubspec.yaml
name: direct_native
description: A powerful framework for building native Dart applications.
version: 0.0.1
homepage: https://github.com/yourusername/direct_native

environment:
  sdk: '>=2.12.0 <3.0.0'

dependencies:
  args: ^2.3.1

dev_dependencies:
  lints: ^2.0.0
  test: ^1.16.0

executables:
  dn: dn
EOF

    # Update README.md
    cat << EOF > README.md
# Direct Native (DN) Framework

A powerful framework for building native Dart applications.

## Getting Started

TODO: Add getting started instructions

## Features

TODO: List key features of the framework

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct, and the process for submitting pull requests.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details
EOF

    # Create initial CONTRIBUTING.md content
    cat << EOF > CONTRIBUTING.md
# Contributing to Direct Native (DN) Framework

We love your input! We want to make contributing to this project as easy and transparent as possible, whether it's:

- Reporting a bug
- Discussing the current state of the code
- Submitting a fix
- Proposing new features

## We Develop with Github

We use github to host code, to track issues and feature requests, as well as accept pull requests.

TODO: Add more specific contribution guidelines
EOF

    echo "Direct Native (DN) framework project structure created successfully!"
}

# Run the function to create the project
create_dn_project