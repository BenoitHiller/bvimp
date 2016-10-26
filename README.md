# bvimp

Bash tool for managing vim 8 packages.

## Warning

This is not at all finished. It may currently be able to add and remove packages, but I in no way guarantee that it works, or that any part of it that works now won't be broken later to extend functionality.

If you want to use it I recommend having a look at what it does, the code is still rather small. It is basically just performing the process described in [this article](https://shapeshed.com/vim-packages/).

## Usage

Before using the program you have to call `bvimp init`.

To install the package in the github repository `user/repository` use the command:

    bvimp add user/repository

This will install the package by setting up the repository as a submodule in `~/.vim/pack/bvimp`.

You can later remove the same package by calling:

    bvimp remove user/repository

If you want to update packages call:

    bvimp update
