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

        The output should include 'base -- ----- ./b b.txt'
        The output should include '---- -- clone ./c.txt'
        The output should include 'base != clone ./dir/2.txt'
        The lines of output should equal 3

        rm -f "$tmp_hashlist1" "$tmp_hashlist2"
    End

    It 'shows difference list with specified identifiers'
        export TAG_BASE=DIR1
        export TAG_CLONE=DIR2

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

        The output should include 'base -- ----- ./b b.txt'
        The output should include '---- -- clone ./c.txt'
        The output should include 'base != clone ./dir/2.txt'
        The lines of output should equal 3

        rm -f "$tmp_hashlist1"
    End

End
