Describe 'comp_hashlist.sh'

    It 'compares two hashlists'
        tmp_hashlist1=`mktemp`
        tmp_hashlist2=`mktemp`

        {
            echo 87428fc522803d31065e7bce3cf03fe475096631e5e07bbd7a0fde60c4cf25c7 ./a.txt
            echo 87428fc522803d31065e7bce3cf03fe475096631e5e07bbd7a0fde60c4cf25c8 ./b b.txt
            echo 87428fc522803d31065e7bce3cf03fe475096631e5e07bbd7a0fde60c4cf25ca ./dir/1.txt
            echo 87428fc522803d31065e7bce3cf03fe475096631e5e07bbd7a0fde60c4cf25cb ./dir/2.txt
        } > "$tmp_hashlist1"

        {
            echo 87428fc522803d31065e7bce3cf03fe475096631e5e07bbd7a0fde60c4cf25c7 ./a.txt
            echo 87428fc522803d31065e7bce3cf03fe475096631e5e07bbd7a0fde60c4cf25c9 ./c.txt
            echo 87428fc522803d31065e7bce3cf03fe475096631e5e07bbd7a0fde60c4cf25ca ./dir/1.txt
            echo 87428fc522803d31065e7bce3cf03fe475096631e5e07bbd7a0fde60c4cf25c0 ./dir/2.txt
        } > "$tmp_hashlist2"


        When call comp_hashlist.sh "$tmp_hashlist1" "$tmp_hashlist2"

        The output should include 'LEFT -- ----- ./b b.txt'
        The output should include '---- -- RIGHT ./c.txt'
        The output should include 'LEFT != RIGHT ./dir/2.txt'
        The lines of output should equal 3

        rm -f "$tmp_hashlist1" "$tmp_hashlist2"
    End

    It 'shows difference list with specified identifiers'
        export TAG_LEFT=DIR1
        export TAG_RIGHT=DIR2

        tmp_hashlist1=`mktemp`
        tmp_hashlist2=`mktemp`

        {
            echo 87428fc522803d31065e7bce3cf03fe475096631e5e07bbd7a0fde60c4cf25c7 ./a.txt
            echo 87428fc522803d31065e7bce3cf03fe475096631e5e07bbd7a0fde60c4cf25c8 ./b b.txt
            echo 87428fc522803d31065e7bce3cf03fe475096631e5e07bbd7a0fde60c4cf25ca ./dir/1.txt
            echo 87428fc522803d31065e7bce3cf03fe475096631e5e07bbd7a0fde60c4cf25cb ./dir/2.txt
        } > "$tmp_hashlist1"

        {
            echo 87428fc522803d31065e7bce3cf03fe475096631e5e07bbd7a0fde60c4cf25c7 ./a.txt
            echo 87428fc522803d31065e7bce3cf03fe475096631e5e07bbd7a0fde60c4cf25c9 ./c.txt
            echo 87428fc522803d31065e7bce3cf03fe475096631e5e07bbd7a0fde60c4cf25ca ./dir/1.txt
            echo 87428fc522803d31065e7bce3cf03fe475096631e5e07bbd7a0fde60c4cf25c0 ./dir/2.txt
        } > "$tmp_hashlist2"


        When call comp_hashlist.sh "$tmp_hashlist1" "$tmp_hashlist2"

        The output should include 'DIR1 -- ---- ./b b.txt'
        The output should include '---- -- DIR2 ./c.txt'
        The output should include 'DIR1 != DIR2 ./dir/2.txt'
        The lines of output should equal 3

        rm -f "$tmp_hashlist1" "$tmp_hashlist2"
    End

    It 'shows difference list with state expressed in number'
        tmp_hashlist1=`mktemp`
        tmp_hashlist2=`mktemp`

        {
            echo 87428fc522803d31065e7bce3cf03fe475096631e5e07bbd7a0fde60c4cf25c7 ./a.txt
            echo 87428fc522803d31065e7bce3cf03fe475096631e5e07bbd7a0fde60c4cf25c8 ./b b.txt
            echo 87428fc522803d31065e7bce3cf03fe475096631e5e07bbd7a0fde60c4cf25ca ./dir/1.txt
            echo 87428fc522803d31065e7bce3cf03fe475096631e5e07bbd7a0fde60c4cf25cb ./dir/2.txt
        } > "$tmp_hashlist1"

        {
            echo 87428fc522803d31065e7bce3cf03fe475096631e5e07bbd7a0fde60c4cf25c7 ./a.txt
            echo 87428fc522803d31065e7bce3cf03fe475096631e5e07bbd7a0fde60c4cf25c9 ./c.txt
            echo 87428fc522803d31065e7bce3cf03fe475096631e5e07bbd7a0fde60c4cf25ca ./dir/1.txt
            echo 87428fc522803d31065e7bce3cf03fe475096631e5e07bbd7a0fde60c4cf25c0 ./dir/2.txt
        } > "$tmp_hashlist2"


        When call comp_hashlist.sh --number-state "$tmp_hashlist1" "$tmp_hashlist2"

        The output should include '1 ./b b.txt'
        The output should include '2 ./c.txt'
        The output should include '3 ./dir/2.txt'
        The lines of output should equal 3

        rm -f "$tmp_hashlist1" "$tmp_hashlist2"
    End

    It 'compares between a hashlist file and a hashlist by stdin'
        tmp_hashlist1=`mktemp`

        {
            echo 87428fc522803d31065e7bce3cf03fe475096631e5e07bbd7a0fde60c4cf25c7 ./a.txt
            echo 87428fc522803d31065e7bce3cf03fe475096631e5e07bbd7a0fde60c4cf25c8 ./b b.txt
            echo 87428fc522803d31065e7bce3cf03fe475096631e5e07bbd7a0fde60c4cf25ca ./dir/1.txt
            echo 87428fc522803d31065e7bce3cf03fe475096631e5e07bbd7a0fde60c4cf25cb ./dir/2.txt
        } > "$tmp_hashlist1"

        Data
            #|87428fc522803d31065e7bce3cf03fe475096631e5e07bbd7a0fde60c4cf25c7 ./a.txt
            #|87428fc522803d31065e7bce3cf03fe475096631e5e07bbd7a0fde60c4cf25c9 ./c.txt
            #|87428fc522803d31065e7bce3cf03fe475096631e5e07bbd7a0fde60c4cf25ca ./dir/1.txt
            #|87428fc522803d31065e7bce3cf03fe475096631e5e07bbd7a0fde60c4cf25c0 ./dir/2.txt
        End


        When call comp_hashlist.sh "$tmp_hashlist1"

        The output should include 'LEFT -- ----- ./b b.txt'
        The output should include '---- -- RIGHT ./c.txt'
        The output should include 'LEFT != RIGHT ./dir/2.txt'
        The lines of output should equal 3

        rm -f "$tmp_hashlist1"
    End

    It 'raises error with unexists left-hashlist'
        tmp_hashlist1=`mktemp`

        {
            echo 87428fc522803d31065e7bce3cf03fe475096631e5e07bbd7a0fde60c4cf25c7 ./a.txt
            echo 87428fc522803d31065e7bce3cf03fe475096631e5e07bbd7a0fde60c4cf25c8 ./b b.txt
            echo 87428fc522803d31065e7bce3cf03fe475096631e5e07bbd7a0fde60c4cf25ca ./dir/1.txt
            echo 87428fc522803d31065e7bce3cf03fe475096631e5e07bbd7a0fde60c4cf25cb ./dir/2.txt
        } > "$tmp_hashlist1"


        When call comp_hashlist.sh ./not_exists "$tmp_hashlist1"

        The status should not equal 0
        The lines of output should equal 0
        The error should include "fatal: cannot open file \`./not_exists' for reading (No such file or directory)"

        rm -f "$tmp_hashlist1"
    End

    It 'raises error with directory as left-hashlist'
        tmp_hashlist1=`mktemp -d`
        tmp_hashlist2=`mktemp`

        {
            echo 87428fc522803d31065e7bce3cf03fe475096631e5e07bbd7a0fde60c4cf25c7 ./a.txt
            echo 87428fc522803d31065e7bce3cf03fe475096631e5e07bbd7a0fde60c4cf25c9 ./c.txt
            echo 87428fc522803d31065e7bce3cf03fe475096631e5e07bbd7a0fde60c4cf25ca ./dir/1.txt
            echo 87428fc522803d31065e7bce3cf03fe475096631e5e07bbd7a0fde60c4cf25c0 ./dir/2.txt
        } > "$tmp_hashlist2"


        When call comp_hashlist.sh "$tmp_hashlist1" "$tmp_hashlist2"

        The status should not equal 0
        The lines of output should equal 0
        The error should include "fatal: cannot open file \`$tmp_hashlist1' for reading (It is a directory)"

        rm -Rf "$tmp_hashlist1" "$tmp_hashlist2"
    End

    It 'raises error with unreadable left-hashlist'
        tmp_hashlist1=`mktemp`
        tmp_hashlist2=`mktemp`
        chmod 222 "$tmp_hashlist1"

        {
            echo 87428fc522803d31065e7bce3cf03fe475096631e5e07bbd7a0fde60c4cf25c7 ./a.txt
            echo 87428fc522803d31065e7bce3cf03fe475096631e5e07bbd7a0fde60c4cf25c8 ./b b.txt
            echo 87428fc522803d31065e7bce3cf03fe475096631e5e07bbd7a0fde60c4cf25ca ./dir/1.txt
            echo 87428fc522803d31065e7bce3cf03fe475096631e5e07bbd7a0fde60c4cf25cb ./dir/2.txt
        } > "$tmp_hashlist1"

        {
            echo 87428fc522803d31065e7bce3cf03fe475096631e5e07bbd7a0fde60c4cf25c7 ./a.txt
            echo 87428fc522803d31065e7bce3cf03fe475096631e5e07bbd7a0fde60c4cf25c9 ./c.txt
            echo 87428fc522803d31065e7bce3cf03fe475096631e5e07bbd7a0fde60c4cf25ca ./dir/1.txt
            echo 87428fc522803d31065e7bce3cf03fe475096631e5e07bbd7a0fde60c4cf25c0 ./dir/2.txt
        } > "$tmp_hashlist2"


        When call comp_hashlist.sh "$tmp_hashlist1" "$tmp_hashlist2"

        The status should not equal 0
        The lines of output should equal 0
        The error should include "fatal: cannot open file \`$tmp_hashlist1' for reading (Permission denied)"

        rm -f "$tmp_hashlist1" "$tmp_hashlist2"
    End

    It 'raises error with unexists right-hashlist'
        tmp_hashlist1=`mktemp`

        {
            echo 87428fc522803d31065e7bce3cf03fe475096631e5e07bbd7a0fde60c4cf25c7 ./a.txt
            echo 87428fc522803d31065e7bce3cf03fe475096631e5e07bbd7a0fde60c4cf25c8 ./b b.txt
            echo 87428fc522803d31065e7bce3cf03fe475096631e5e07bbd7a0fde60c4cf25ca ./dir/1.txt
            echo 87428fc522803d31065e7bce3cf03fe475096631e5e07bbd7a0fde60c4cf25cb ./dir/2.txt
        } > "$tmp_hashlist1"


        When call comp_hashlist.sh "$tmp_hashlist1" ./not_exists

        The status should not equal 0
        The lines of output should equal 0
        The error should include "fatal: cannot open file \`./not_exists' for reading (No such file or directory)"

        rm -f "$tmp_hashlist1"
    End

    It 'raises error with directory as right-hashlist'
        tmp_hashlist1=`mktemp`
        tmp_hashlist2=`mktemp -d`

        {
            echo 87428fc522803d31065e7bce3cf03fe475096631e5e07bbd7a0fde60c4cf25c7 ./a.txt
            echo 87428fc522803d31065e7bce3cf03fe475096631e5e07bbd7a0fde60c4cf25c9 ./c.txt
            echo 87428fc522803d31065e7bce3cf03fe475096631e5e07bbd7a0fde60c4cf25ca ./dir/1.txt
            echo 87428fc522803d31065e7bce3cf03fe475096631e5e07bbd7a0fde60c4cf25c0 ./dir/2.txt
        } > "$tmp_hashlist1"


        When call comp_hashlist.sh "$tmp_hashlist1" "$tmp_hashlist2"

        The status should not equal 0
        The lines of output should equal 0
        The error should include "fatal: cannot open file \`$tmp_hashlist2' for reading (It is a directory)"

        rm -Rf "$tmp_hashlist1" "$tmp_hashlist2"
    End

    It 'raises error with unreadable right-hashlist'
        tmp_hashlist1=`mktemp`
        tmp_hashlist2=`mktemp`
        chmod 222 "$tmp_hashlist2"

        {
            echo 87428fc522803d31065e7bce3cf03fe475096631e5e07bbd7a0fde60c4cf25c7 ./a.txt
            echo 87428fc522803d31065e7bce3cf03fe475096631e5e07bbd7a0fde60c4cf25c8 ./b b.txt
            echo 87428fc522803d31065e7bce3cf03fe475096631e5e07bbd7a0fde60c4cf25ca ./dir/1.txt
            echo 87428fc522803d31065e7bce3cf03fe475096631e5e07bbd7a0fde60c4cf25cb ./dir/2.txt
        } > "$tmp_hashlist1"

        {
            echo 87428fc522803d31065e7bce3cf03fe475096631e5e07bbd7a0fde60c4cf25c7 ./a.txt
            echo 87428fc522803d31065e7bce3cf03fe475096631e5e07bbd7a0fde60c4cf25c9 ./c.txt
            echo 87428fc522803d31065e7bce3cf03fe475096631e5e07bbd7a0fde60c4cf25ca ./dir/1.txt
            echo 87428fc522803d31065e7bce3cf03fe475096631e5e07bbd7a0fde60c4cf25c0 ./dir/2.txt
        } > "$tmp_hashlist2"


        When call comp_hashlist.sh "$tmp_hashlist1" "$tmp_hashlist2"

        The status should not equal 0
        The lines of output should equal 0
        The error should include "fatal: cannot open file \`$tmp_hashlist2' for reading (Permission denied)"

        rm -f "$tmp_hashlist1" "$tmp_hashlist2"
    End

End
