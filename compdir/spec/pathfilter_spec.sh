Describe 'pathfilter.sh'

    It 'behaves like sed without -f option'
        Mock sed
            while (( $# > 0 )); do
                echo "arg:$1"
                shift
            done
            cat -
        End

        Data
            #|/home/username/example1
            #|/home/username/example2
        End

        When call pathfilter.sh -z -e 's/username/USER/g'

        The line 1 of output should equal 'arg:-z'
        The line 2 of output should equal 'arg:-e'
        The line 3 of output should equal 'arg:s/username/USER/g'
        The line 4 of output should equal '/home/username/example1'
        The line 5 of output should equal '/home/username/example2'
        The lines of output should equal 5
    End

    It 'interprets -f file as filter condition'
        tmp_condlist=`mktemp`

        Data
            #|/home/username/example1
            #|/home/username/example2
            #|/home/username/deny/E1
            #|/home/username/deny/E2
            #|/home/username/deny/acc/e1
            #|/home/username/deny/acc/e2
        End

        {
            echo D /home/username/deny
            echo A /home/username/deny/acc
        } > "$tmp_condlist"

        When call pathfilter.sh -f "$tmp_condlist"

        The line 1 of output should equal '/home/username/example1'
        The line 2 of output should equal '/home/username/example2'
        The line 3 of output should equal '/home/username/deny/acc/e1'
        The line 4 of output should equal '/home/username/deny/acc/e2'
        The lines of output should equal 4

        rm -f "$tmp_condlist"
    End
End
