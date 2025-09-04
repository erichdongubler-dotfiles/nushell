module completions {

  def "nu-complete pueue color" [] {
    [ "auto" "never" "always" ]
  }

  # Interact with the Pueue daemon  Use the `--help` long form to get detailed help output on each subcommand!
  export extern pueue [
    --verbose(-v)             # Verbose mode (-v, -vv, -vvv)
    --color: string@"nu-complete pueue color" # Colorize the output; auto enables color output when connected to a tty
    --config(-c): path        # If provided, Pueue only uses this config file
    --profile(-p): string     # The name of the profile that should be loaded from your config file
    --help(-h)                # Print help (see more with '--help')
    --version(-V)             # Print version
  ]

  # Enqueue a task for execution
  export extern "pueue add" [
    ...command: string        # The command to be added
    --working-directory(-w): path # Specify current working directory
    --escape(-e)              # Escape any special shell characters (" ", "&", "!", etc.). Beware: This implicitly disables nearly all shell specific syntax ("&&", "&>").
    --immediate(-i)           # Immediately start the task
    --follow                  # Immediately follow a task, if it's started with --immediate
    --stashed(-s)             # Create the task in Stashed state
    --delay(-d): string       # Prevents the task from being enqueued until 'delay' elapses. See "enqueue" for accepted formats
    --group(-g): string       # Assign the task to a group
    --after(-a): string       # Start the task once all specified tasks have successfully finished
    --priority(-o): string    # Start this task with a higher priority
    --label(-l): string       # Add some information for yourself
    --print-task-id(-p)       # Only return the task id instead of a text
    --help(-h)                # Print help (see more with '--help')
  ]

  # Remove tasks from the list. Running or paused tasks need to be killed first
  export extern "pueue remove" [
    ...task_ids: string       # The task ids to be removed
    --help(-h)                # Print help
  ]

  # Switches the queue position of two commands
  export extern "pueue switch" [
    task_id_1: string         # The first task id
    task_id_2: string         # The second task id
    --help(-h)                # Print help (see more with '--help')
  ]

  # Stash a task. Stashed tasks won't be automatically started
  export extern "pueue stash" [
    ...task_ids: string       # Stash these specific tasks
    --group(-g): string       # Stash all queued tasks in a group
    --all(-a)                 # Stash all queued tasks across all groups
    --delay(-d): string       # Delay enqueuing these tasks until 'delay' elapses. See DELAY FORMAT below
    --help(-h)                # Print help (see more with '--help')
  ]

  # Enqueue stashed tasks. They'll be handled normally afterwards
  export extern "pueue enqueue" [
    ...task_ids: string       # Enqueue these specific tasks
    --group(-g): string       # Enqueue all stashed tasks in a group
    --all(-a)                 # Enqueue all stashed tasks across all groups
    --delay(-d): string       # Delay enqueuing these tasks until 'delay' elapses. See DELAY FORMAT below
    --help(-h)                # Print help (see more with '--help')
  ]

  # Resume operation of specific tasks or groups of tasks
  export extern "pueue start" [
    ...task_ids: string       # Start these specific tasks. Paused tasks will resumed. Queued/Stashed tasks will be force-started
    --group(-g): string       # Resume a specific group and all paused tasks in it
    --all(-a)                 # Resume all groups!
    --help(-h)                # Print help (see more with '--help')
  ]

  # Restart failed or successful task(s)
  export extern "pueue restart" [
    ...task_ids: string       # Restart these specific tasks
    --all-failed(-a)          # Restart all failed tasks across all groups
    --failed-in-group(-g): string # Like `--all-failed`, but only restart tasks failed tasks of a specific group
    --immediate(-k)           # Immediately start the tasks, no matter how many open slots there are. This will ignore any dependencies tasks may have
    --stashed(-s)             # Set the restarted task to a "Stashed" state. Useful to avoid immediate execution
    --in-place(-i)            # Restart the task by reusing the already existing tasks. This will overwrite any previous logs of the restarted tasks
    --not-in-place            # Restart the task by creating a new identical tasks. Only necessary if you have the `restart_in_place` configuration set to true
    --edit(-e)                # Edit the task before restarting
    --help(-h)                # Print help (see more with '--help')
  ]

  # Either pause running tasks or specific groups of tasks
  export extern "pueue pause" [
    ...task_ids: string       # Pause these specific tasks
    --group(-g): string       # Pause a specific group
    --all(-a)                 # Pause all groups!
    --wait(-w)                # Pause the specified groups, but let already running tasks finish by themselves
    --help(-h)                # Print help (see more with '--help')
  ]

  # Kill specific running tasks or whole task groups
  export extern "pueue kill" [
    ...task_ids: string       # Kill these specific tasks
    --group(-g): string       # Kill all running tasks in a group. This also pauses the group
    --all(-a)                 # Kill all running tasks across ALL groups. This also pauses all groups
    --signal(-s): string      # Send a UNIX signal instead of simply killing the process
    --help(-h)                # Print help (see more with '--help')
  ]

  # Send something to a task. Useful for sending confirmations such as 'y\n'
  export extern "pueue send" [
    task_id: string           # The id of the task
    input: string             # The input that should be sent to the process
    --help(-h)                # Print help
  ]

  # Adjust editable properties of a task
  export extern "pueue edit" [
    ...task_ids: string       # The ids of all tasks that should be edited
    --help(-h)                # Print help (see more with '--help')
  ]

  # Use this to add or remove environment variables from tasks
  export extern "pueue env" [
    --help(-h)                # Print help
  ]

  # Set a variable for a specific task's environment
  export extern "pueue env set" [
    task_id: string           # The id of the task for which the variable should be set
    key: string               # The name of the environment variable to set
    value: string             # The value of the environment variable to set
    --help(-h)                # Print help
  ]

  # Remove a specific variable from a task's environment
  export extern "pueue env unset" [
    task_id: string           # The id of the task for which the variable should be set
    key: string               # The name of the environment variable to set
    --help(-h)                # Print help
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "pueue env help" [
  ]

  # Set a variable for a specific task's environment
  export extern "pueue env help set" [
  ]

  # Remove a specific variable from a task's environment
  export extern "pueue env help unset" [
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "pueue env help help" [
  ]

  # Use this to add or remove groups
  export extern "pueue group" [
    --json(-j)                # Print the list of groups as json
    --help(-h)                # Print help (see more with '--help')
  ]

  # Add a group by name
  export extern "pueue group add" [
    name: string
    --parallel(-p): string    # Set the amount of parallel tasks this group can have
    --help(-h)                # Print help (see more with '--help')
  ]

  # Remove a group by name. This will move all tasks in this group to the default group!
  export extern "pueue group remove" [
    name: string
    --help(-h)                # Print help
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "pueue group help" [
  ]

  # Add a group by name
  export extern "pueue group help add" [
  ]

  # Remove a group by name. This will move all tasks in this group to the default group!
  export extern "pueue group help remove" [
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "pueue group help help" [
  ]

  # Display the current status of all tasks
  export extern "pueue status" [
    ...query: string          # Users can specify a custom query to filter for specific values, order by a column or limit the amount of tasks listed. Use `--help` for the full syntax definition
    --json(-j)                # Print the current state as json to stdout. This does not include the output of tasks. Use `log -j` if you want everything
    --group(-g): string       # Only show tasks of a specific group
    --help(-h)                # Print help (see more with '--help')
  ]

  # Display the log output of finished tasks
  export extern "pueue log" [
    ...task_ids: string       # View the task output of these specific tasks
    --group(-g): string       # View the outputs of this specific group's tasks
    --all(-a)                 # Show the logs of all groups' tasks
    --json(-j)                # Print the resulting tasks and output as json
    --lines(-l): string       # Only print the last X lines of each task's output
    --full(-f)                # Show the whole output
    --help(-h)                # Print help (see more with '--help')
  ]

  # Follow the output of a currently running task. This command works like "tail -f"
  export extern "pueue follow" [
    task_id?: string          # The id of the task you want to watch
    --lines(-l): string       # Only print the last X lines of the output before following
    --help(-h)                # Print help (see more with '--help')
  ]

  # Wait until tasks are finished
  export extern "pueue wait" [
    ...task_ids: string       # This allows you to wait for specific tasks to finish
    --group(-g): string       # Wait for all tasks in a specific group
    --all(-a)                 # Wait for all tasks across all groups and the default group
    --quiet(-q)               # Don't show any log output while waiting
    --status(-s): string      # Wait for tasks to reach a specific task status
    --help(-h)                # Print help (see more with '--help')
  ]

  # Remove all finished tasks from the list
  export extern "pueue clean" [
    --successful-only(-s)     # Only clean tasks that finished successfully
    --group(-g): string       # Only clean tasks of a specific group
    --help(-h)                # Print help
  ]

  # Kill all tasks, clean up afterwards and reset EVERYTHING!
  export extern "pueue reset" [
    --groups(-g): string      # If groups are specified, only those specific groups will be reset
    --force(-f)               # Don't ask for any confirmation
    --help(-h)                # Print help
  ]

  # Remotely shut down the daemon. Should only be used if the daemon isn't started by a service manager
  export extern "pueue shutdown" [
    --help(-h)                # Print help
  ]

  # Set the amount of allowed parallel tasks
  export extern "pueue parallel" [
    parallel_tasks?: string   # The amount of allowed parallel tasks
    --group(-g): string       # Set the amount for a specific group
    --help(-h)                # Print help (see more with '--help')
  ]

  def "nu-complete pueue completions shell" [] {
    [ "bash" "elvish" "fish" "power-shell" "zsh" "nushell" ]
  }

  # Generates shell completion files
  export extern "pueue completions" [
    shell: string@"nu-complete pueue completions shell" # The target shell
    output_directory?: path   # The output directory to which the file should be written
    --help(-h)                # Print help (see more with '--help')
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "pueue help" [
  ]

  # Enqueue a task for execution
  export extern "pueue help add" [
  ]

  # Remove tasks from the list. Running or paused tasks need to be killed first
  export extern "pueue help remove" [
  ]

  # Switches the queue position of two commands
  export extern "pueue help switch" [
  ]

  # Stash a task. Stashed tasks won't be automatically started
  export extern "pueue help stash" [
  ]

  # Enqueue stashed tasks. They'll be handled normally afterwards
  export extern "pueue help enqueue" [
  ]

  # Resume operation of specific tasks or groups of tasks
  export extern "pueue help start" [
  ]

  # Restart failed or successful task(s)
  export extern "pueue help restart" [
  ]

  # Either pause running tasks or specific groups of tasks
  export extern "pueue help pause" [
  ]

  # Kill specific running tasks or whole task groups
  export extern "pueue help kill" [
  ]

  # Send something to a task. Useful for sending confirmations such as 'y\n'
  export extern "pueue help send" [
  ]

  # Adjust editable properties of a task
  export extern "pueue help edit" [
  ]

  # Use this to add or remove environment variables from tasks
  export extern "pueue help env" [
  ]

  # Set a variable for a specific task's environment
  export extern "pueue help env set" [
  ]

  # Remove a specific variable from a task's environment
  export extern "pueue help env unset" [
  ]

  # Use this to add or remove groups
  export extern "pueue help group" [
  ]

  # Add a group by name
  export extern "pueue help group add" [
  ]

  # Remove a group by name. This will move all tasks in this group to the default group!
  export extern "pueue help group remove" [
  ]

  # Display the current status of all tasks
  export extern "pueue help status" [
  ]

  # Display the log output of finished tasks
  export extern "pueue help log" [
  ]

  # Follow the output of a currently running task. This command works like "tail -f"
  export extern "pueue help follow" [
  ]

  # Wait until tasks are finished
  export extern "pueue help wait" [
  ]

  # Remove all finished tasks from the list
  export extern "pueue help clean" [
  ]

  # Kill all tasks, clean up afterwards and reset EVERYTHING!
  export extern "pueue help reset" [
  ]

  # Remotely shut down the daemon. Should only be used if the daemon isn't started by a service manager
  export extern "pueue help shutdown" [
  ]

  # Set the amount of allowed parallel tasks
  export extern "pueue help parallel" [
  ]

  # Generates shell completion files
  export extern "pueue help completions" [
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "pueue help help" [
  ]

}

export use completions *
