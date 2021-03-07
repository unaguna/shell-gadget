Describe 'collate.sh'

    It 'succeeds if the collect answer is input at first time'
        Data
            #|word1
            #|dummy
        End

        When call collate.sh word1

        The status should equal 0
        The lines of output should equal 1
        The line 1 of output should equal '> '
    End

    It 'succeeds if the collect answer is input at second time'
        Data
            #|dummy-A
            #|word1
        End

        When call collate.sh word1

        The status should equal 0
        The lines of output should equal 1
        The line 1 of output should equal '> > '
        The lines of error should equal 1
        The line 1 of error should include 'dummy-A'
    End

    It 'succeeds if one of the collect answers is input at first time'
        Data
            #|word2
            #|dummy
        End

        When call collate.sh word1 word2

        The status should equal 0
        The lines of output should equal 1
        The line 1 of output should equal '> '
    End

    It 'fails if [EOF] is input at first time'
        # 空の入力
        Data
        End

        When call collate.sh word1

        The status should equal 120
        The lines of output should equal 1
        The line 1 of output should equal '> '
    End

    It 'fails if [EOF] is input before a correct answer'
        # 空の入力
        Data
            #|dummy-A
            #|dummy-B
        End

        When call collate.sh word1

        The status should equal 120
        The lines of output should equal 1
        The line 1 of output should equal '> > > '
        The lines of error should equal 2
        The line 1 of error should include 'dummy-A'
        The line 2 of error should include 'dummy-B'
    End

    It 'succeeds if the collect answer is input at first time (with -r)'
        Data
            #|word1
            #|dummy
        End

        When call collate.sh -r 2 word1

        The status should equal 0
        The lines of output should equal 1
        The line 1 of output should equal '> '
    End

    It 'succeeds if the collect answer is input until retry limit'
        Data
            #|dummy-A
            #|word1
        End

        When call collate.sh -r 2 word1

        The status should equal 0
        The lines of output should equal 1
        The line 1 of output should equal '> > '
        The lines of error should equal 1
        The line 1 of error should include 'dummy-A'
    End

    It 'fails if the collect answer is not input until retry limit'
        # 空の入力
        Data
            #|dummy-A
            #|dummy-B
            #|dummy
        End

        When call collate.sh -r 2 word1

        The status should equal 120
        The lines of output should equal 1
        The line 1 of output should equal '> > '
        The lines of error should equal 2
        The line 1 of error should include 'dummy-A'
        The line 2 of error should include 'dummy-B'
    End

    It 'succeeds if one of the collect answers is input at first time (with -r)'
        Data
            #|word2
            #|dummy
        End

        When call collate.sh -r 1 word1 word2

        The status should equal 0
        The lines of output should equal 1
        The line 1 of output should equal '> '
    End

    It 'fails with illegal retry-number (not a number)'
        When call collate.sh -r word1 word2

        The status should not equal 0
        The status should not equal 120
        The lines of output should equal 0
        The lines of error should not equal 0
    End

    It 'fails with illegal retry-number (empty)'
        When call collate.sh -r

        The status should not equal 0
        The status should not equal 120
        The lines of output should equal 0
        The lines of error should not equal 0
    End

End
