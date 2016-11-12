# bvimp

Bash tool for managing vim 8 packages.

Pronounced like blimp.

## Warning

This is not at all finished. It may currently be able to add and remove packages, but I in no way guarantee that it works, or that any part of it that works now won't be broken later to extend functionality.

If you want to use it I recommend having a look at what it does, the code is still rather small. It is basically just performing the process described in [this article](https://shapeshed.com/vim-packages/).

## Usage

Before using the program you have to call `bvimp init`.

To install the package in the github repository `user/repository` use the command:

    bvimp add [user/]repository

This will install the package by setting up the repository as a submodule in `~/.vim/pack/bvimp`.

If you do not specify the user bvimp will query github for repositories with the specified name and will prompt you with a selection.

You can later remove the same package by calling:

    bvimp remove [user/]repository

It will similarly search your installed packages if you only provide the repository name.

If you want to search git for repositories with a given name you can use the find command.

    bvimp find repository

If you want to update packages call:

    bvimp update

To list all of the currently installed packages use:

    bvimp list

## Configuration

It is possible to specify the directory where bvimp installs packages. It reads this value from the environment variable `BVIMP_HOME` which by default is `$HOME/.vim/pack/bvimp`.
