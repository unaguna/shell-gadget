Describe 'compdir.sh'
    left_dir=spec/sampledir/sample_left
    right_dir=spec/sampledir/sample_right

    It 'compares two directories'
        When call compdir.sh "$left_dir" "$right_dir"

        The output should include 'LEFT -- ----- ./s s.txt'
        The output should include 'LEFT != RIGHT ./b.txt'
        The output should include 'LEFT -- ----- ./c.txt'
        The output should include '---- -- RIGHT ./d.txt'
        The output should include 'LEFT -- ----- ./dir/2.txt'
        The lines of output should equal 5
    End

    It 'compares two target directories'
        When call compdir.sh -t dir "$left_dir" "$right_dir"

        The output should include 'LEFT -- ----- dir/2.txt'
        The lines of output should equal 1
    End

    It 'compares two target directories (2)'
        When call compdir.sh -t dir -t b.txt "$left_dir" "$right_dir"

        The output should include 'LEFT != RIGHT b.txt'
        The output should include 'LEFT -- ----- dir/2.txt'
        The lines of output should equal 2
    End

    It 'compares two directories with filter'
        tmp_condlist=`mktemp`

        {
            echo D ./dir
            echo A /dir/ap
        } > "$tmp_condlist"

        When call compdir.sh -f "$tmp_condlist" "$left_dir" "$right_dir"

        The output should include 'LEFT -- ----- ./s s.txt'
        The output should include 'LEFT != RIGHT ./b.txt'
        The output should include 'LEFT -- ----- ./c.txt'
        The output should include '---- -- RIGHT ./d.txt'
        The lines of output should equal 4
    End

    It 'shows difference list with specified identifiers'
        export TAG_LEFT=DIR1
        export TAG_RIGHT=DIR2

        When call compdir.sh "$left_dir" "$right_dir"

        The output should include 'DIR1 -- ---- ./s s.txt'
        The output should include 'DIR1 != DIR2 ./b.txt'
        The output should include 'DIR1 -- ---- ./c.txt'
        The output should include '---- -- DIR2 ./d.txt'
        The output should include 'DIR1 -- ---- ./dir/2.txt'
        The lines of output should equal 5
    End

    It 'compares the the hashlist and directory'
        tmp_hashlist1=`mktemp`

        hashlist.sh "$left_dir" > "$tmp_hashlist1"

        When call compdir.sh -L "$tmp_hashlist1" "$right_dir"

        The output should include 'LEFT -- ----- ./s s.txt'
        The output should include 'LEFT != RIGHT ./b.txt'
        The output should include 'LEFT -- ----- ./c.txt'
        The output should include '---- -- RIGHT ./d.txt'
        The output should include 'LEFT -- ----- ./dir/2.txt'
        The lines of output should equal 5

        rm -f "$tmp_hashlist1"
    End

    It 'compares the the directory and hashlist'
        tmp_hashlist1=`mktemp`

        hashlist.sh "$right_dir" > "$tmp_hashlist1"

        When call compdir.sh -R "$tmp_hashlist1" "$left_dir"

        The output should include 'LEFT -- ----- ./s s.txt'
        The output should include 'LEFT != RIGHT ./b.txt'
        The output should include 'LEFT -- ----- ./c.txt'
        The output should include '---- -- RIGHT ./d.txt'
        The output should include 'LEFT -- ----- ./dir/2.txt'
        The lines of output should equal 5

        rm -f "$tmp_hashlist1"
    End

    It 'compares the two hashlists'
        tmp_hashlist1=`mktemp`
        tmp_hashlist2=`mktemp`

        hashlist.sh "$left_dir" > "$tmp_hashlist1"
        hashlist.sh "$right_dir" > "$tmp_hashlist2"

        When call compdir.sh -L "$tmp_hashlist1" -R "$tmp_hashlist2"

        The output should include 'LEFT -- ----- ./s s.txt'
        The output should include 'LEFT != RIGHT ./b.txt'
        The output should include 'LEFT -- ----- ./c.txt'
        The output should include '---- -- RIGHT ./d.txt'
        The output should include 'LEFT -- ----- ./dir/2.txt'
        The lines of output should equal 5

        rm -f "$tmp_hashlist1" "$tmp_hashlist2"
    End

    It 'compares the hashlist and the directory with filter'
        tmp_hashlist1=`mktemp`
        tmp_condlist=`mktemp`

        {
            echo D ./dir
            echo A /dir/ap
        } > "$tmp_condlist"

        hashlist.sh -f "$tmp_condlist" "$left_dir" > "$tmp_hashlist1"

        When call compdir.sh -f "$tmp_condlist" -L "$tmp_hashlist1" "$right_dir"

        The output should include 'LEFT -- ----- ./s s.txt'
        The output should include 'LEFT != RIGHT ./b.txt'
        The output should include 'LEFT -- ----- ./c.txt'
        The output should include '---- -- RIGHT ./d.txt'
        The lines of output should equal 4

        rm -f "$tmp_hashlist1"
    End

    It 'compares the directory and the hashlist with filter'
        tmp_hashlist1=`mktemp`
        tmp_condlist=`mktemp`

        {
            echo D ./dir
            echo A /dir/ap
        } > "$tmp_condlist"

        hashlist.sh -f "$tmp_condlist" "$right_dir" > "$tmp_hashlist1"

        When call compdir.sh -f "$tmp_condlist" -R "$tmp_hashlist1" "$left_dir"

        The output should include 'LEFT -- ----- ./s s.txt'
        The output should include 'LEFT != RIGHT ./b.txt'
        The output should include 'LEFT -- ----- ./c.txt'
        The output should include '---- -- RIGHT ./d.txt'
        The lines of output should equal 4

        rm -f "$tmp_hashlist1"
    End

End
