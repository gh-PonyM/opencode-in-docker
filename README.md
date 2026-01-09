# opencode in docker

Opinionated docker image to run opencode in docker.

## Usage

You can build the container:

    ./build.sh

An example shell script is provided to run the container:

    ./run.sh

### Configuration

- `OPENCODE_DOTFILES_LOCAL`: If your local `~/.config/opencode` contain symlinks to dotfiles repos, set this variable.

## Inspirations

- https://github.com/anthropics/claude-code/tree/main/.devcontainer
- https://agileweboperations.com/2025/11/23/how-to-run-opencode-ai-in-a-docker-container/
- https://github.com/junegunn/fzf?tab=readme-ov-file#using-git
