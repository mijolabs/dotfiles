# Prevent pip from installing packages globally
export PIP_REQUIRE_VIRTUALENV=true

alias pip='noglob pip'
alias pip3='noglob pip3'
