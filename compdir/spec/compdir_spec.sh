Describe 'compdir.sh'
    base_dir=spec/sampledir/sample_base
    copy_dir=spec/sampledir/sample_copy

    It 'compares two directories'
        When call compdir.sh "$base_dir" "$copy_dir"

        The output should include 'base -- ----- ./s s.txt'
        The output should include 'base != clone ./b.txt'
        The output should include 'base -- ----- ./c.txt'
        The output should include '---- -- clone ./d.txt'
        The output should include 'base -- ----- ./dir/2.txt'
        The lines of output should equal 5
    End

    It 'compares two target directories'
        When call compdir.sh -t dir "$base_dir" "$copy_dir"

        The output should include 'base -- ----- dir/2.txt'
        The lines of output should equal 1
    End

    It 'compares two directories with filter'
        tmp_condlist=`mktemp`

        {
            echo D ./dir
            echo A /dir/ap
        } > "$tmp_condlist"

        When call compdir.sh -f "$tmp_condlist" "$base_dir" "$copy_dir"

        The output should include 'base -- ----- ./s s.txt'
        The output should include 'base != clone ./b.txt'
        The output should include 'base -- ----- ./c.txt'
        The output should include '---- -- clone ./d.txt'
        The lines of output should equal 4
    End

    It 'shows difference list with specified identifiers'
        export TAG_BASE=DIR1
        export TAG_CLONE=DIR2

        When call compdir.sh "$base_dir" "$copy_dir"

        The output should include 'DIR1 -- ---- ./s s.txt'
        The output should include 'DIR1 != DIR2 ./b.txt'
        The output should include 'DIR1 -- ---- ./c.txt'
        The output should include '---- -- DIR2 ./d.txt'
        The output should include 'DIR1 -- ---- ./dir/2.txt'
        The lines of output should equal 5
    End

    It 'compares the directory and the hashlist'
        tmp_hashlist1=`mktemp`

        hashlist.sh "$base_dir" > "$tmp_hashlist1"

        When call compdir.sh -b "$tmp_hashlist1" "$copy_dir"

        The output should include 'base -- ----- ./s s.txt'
        The output should include 'base != clone ./b.txt'
        The output should include 'base -- ----- ./c.txt'
        The output should include '---- -- clone ./d.txt'
        The output should include 'base -- ----- ./dir/2.txt'
        The lines of output should equal 5

        rm -f "$tmp_hashlist1"
    End

    It 'compares the directory and the hashlist with filter'
        tmp_hashlist1=`mktemp`
        tmp_condlist=`mktemp`

        {
            echo D ./dir
            echo A /dir/ap
        } > "$tmp_condlist"

        hashlist.sh -f "$tmp_condlist" "$base_dir" > "$tmp_hashlist1"

        When call compdir.sh -f "$tmp_condlist" -b "$tmp_hashlist1" "$copy_dir"

        The output should include 'base -- ----- ./s s.txt'
        The output should include 'base != clone ./b.txt'
        The output should include 'base -- ----- ./c.txt'
        The output should include '---- -- clone ./d.txt'
        The lines of output should equal 4

        rm -f "$tmp_hashlist1"
    End

End
