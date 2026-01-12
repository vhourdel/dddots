function gzl --wraps='bzl //:gazelle -- domains/sds' --wraps='bzl run //:gazelle -- domains/sds' --description 'alias gzl=bzl run //:gazelle -- domains/sds'
    bzl run //:gazelle -- domains/sds $argv
end
