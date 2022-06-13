#!/usr/bin/env bats

load _helper
load path

setup() {
    mkdir -p tmp/ellipsis_home
    export ELLIPSIS_HOME=tmp/ellipsis_home
}

teardown() {
    rm -rf tmp
}

@test "path.relative_to_home should print path relative to $HOME" {
    run path.relative_to_home "$HOME/.ellipsis"
    [ "$output" = "~/.ellipsis" ]
    run path.relative_to_home ~/.ellipsis
    [ "$output" = "~/.ellipsis" ]
    run path.relative_to_home $TESTS_DIR2/tmp
    [ "$output" = "~${TESTS_DIR2##$HOME}/tmp" ]
}

@test "path.expand expands '~/', '\$HOME' and '\$ELLIPSIS_HOME' to \$HOME or \$ELLIPSIS_HOME" {
    run path.expand '~/.ellipsis'
    [ "$output" = "$HOME/.ellipsis" ]
    run path.expand '$HOME/.ellipsis'
    [ "$output" = "$HOME/.ellipsis" ]
    run path.expand '$ELLIPSIS_HOME/.ellipsis'
    [ "$output" = "$ELLIPSIS_HOME/.ellipsis" ]
    run path.expand "tmp"
    [ "$output" = "tmp" ]
}
