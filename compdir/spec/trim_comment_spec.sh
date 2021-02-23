Describe 'trim_comment.sh'

    It 'ignores strings between # and EOL in input file'
        When call trim_comment.sh <(
            echo "/home/username/example1"
            echo "#comment"
            echo
            echo "/home/username/example2#it_is_comment"
        )

        The line 1 of output should equal '/home/username/example1'
        The line 2 of output should equal '/home/username/example2'
        The lines of output should equal 2
    End

    It 'ignores strings between # and EOL in stdin'
        Data
            #|/home/username/example1
            #|#comment
            #|
            #|/home/username/example2#it_is_comment
        End

        When call trim_comment.sh

        The line 1 of output should equal '/home/username/example1'
        The line 2 of output should equal '/home/username/example2'
        The lines of output should equal 2
    End
End
