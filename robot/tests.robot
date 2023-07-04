*** Settings ***
Documentation       Different RF features tested in this test suite
...                 including the latest RF 6.1 features (tagged with rf6.1)
...
...                 Run the tests with:
...
...                ``robot -d results -L TRACE --listener RobotStackTracer -v name:value:with:colons -v another:value <path/to/>tests.robot``    # robocop:disable=0508

Library             DateTime
Library             ../utils/stuffz.py    # Import module
Library             stuffz.ConversionLibrary    # Import class from the module


*** Variables ***
${NAME}         ${None}
${ANOTHER}      ${None}


*** Test Cases ***
Testcase Number One
    [Documentation]    Execute this test case with giving variables As
    ...    *-v* commandline_passed_name:value:with:colons *-v* commandline_passedanother:value
    Log    ${NAME}
    Log    ${ANOTHER}
    stuffz.Call Independent Function From Module With Class
    Keyword With Integer Value 75 Float Value 4.563 And String here's a string    # robocop:disable=0302

Example Date Conversions
    [Documentation]    This shows the library import and custom argument conversions
    Finnish Format    25.1.2022
    US Format    1/25/2022
    ISO 8601    2022-01-22

Do Not Match Whitespace Characters
    [Documentation]    Using custom regular expressions for strings
    Select Chicago Bulls
    Select Los Angeles Lakers

Match Numbers And Characters From Set
    [Documentation]    Using custom regular expressions for numbers and characters
    1 + 2 = 3
    53 - 11 = 42
    First + Second = First Second
    Run Keyword And Expect Error    Operator "-" operation not implemented!    F - S = F

Match Either Date Or Today
    [Documentation]    [Documentation]    Using custom regular expressions for DateTime
    Deadline Is 2023-09-21
    Deadline Is today    # robocop:disable=0302
    Deadline Is Today

Testcase Documentation With Spaces
    [Documentation]    Bunch of items in a list:
    ...    - First item
    ...    - Second item in multiple lines with spaces preserved
    ...    first part
    ...    followed by the second part
    ...    etc.
    ...    - Third item
    ...    Example with consecutive internal spaces:
    ...
    ...    | ***** Test Cases *****
    ...    | Example
    ...    |    Keyword
    ...    New in RF 6.1
    [Tags]    rf6.1
    Log Many    It is possible to have leading spaces and consecutive internal spaces
    ...    preserved in RF 6.1 in documentation and in metadata which were earlier escaped
    ...    with a \\

Serialize And Deserialize Testsuite To And From JSON
    [Documentation]    Tryout JSON conversion to and from for Testsuite, new in RF 6.1
    [Tags]    rf6.1    json_conv
    ${serialized_suite} =    Call Serialization Function    ${SUITE SOURCE}
    ${deserialized} =    Call Deserialization Function    ${serialized_suite}
    @{testcases} =    Evaluate    [i.name for i in ${deserialized.tests._items}]
    Log    Testsuite name: ${deserialized.name}
    Log Many    Testcases:    @{testcases}

Use Both Embedded And Regular Arguments
    [Documentation]    RF 6.1 allows both embedded and regular arguments!?
    [Tags]    rf6.1
    Keyword With Embedded-Argument As Well As Regulars    Regular    Arguments

Flatten Keyword For Repeated Keyword Calls
    [Documentation]    Trying out two new features of RF 6.1
    ...    1. Assignment to lists and dicts
    ...    2. Flattern keyword structures with tag
    [Tags]    rf6.1
    Item Assignment To List
    Item Assignment To Dictionary
    Different Ways Of Assigning Values With Flattened Keywords


*** Keywords ***
Select ${city} ${team:\S+}
    [Documentation]    Embedding variables here allows for city name with space
    Log    Selected ${team} from ${city}.

${number1:\d+} ${operator:[+-]} ${number2:\d+} = ${expected:\d+}
    [Documentation]    Match numbers from given set
    ${result} =    Evaluate    ${number1} ${operator} ${number2}
    Should Be Equal As Integers    ${result}    ${expected}

${string1:\D+} ${operator:[+-/*]} ${string2:\D+} = ${expected:\D+}
    [Documentation]    Match strings from given set
    IF    "${operator}" == "+"
        ${result} =    Catenate    ${string1}    ${string2}
        Should Be Equal As Strings    ${result}    ${expected}
    ELSE
        Fail    Operator "${operator}" operation not implemented!
    END

Deadline Is ${date:(\d{4}-\d{2}-\d{2}|[tT]oday)}
    [Documentation]    Use regular expression to calculate date
    Log    ${date}
    IF    '${date.lower()}' == 'today'
        ${date} =    Get Current Date
    ELSE
        ${date} =    Convert Date    ${date}
    END
    Log    Deadline is on ${date}

Keyword With ${embedded_argument} As Well As Regulars
    [Documentation]    Use both embedded and normal arguments
    [Arguments]    ${regular1}    ${regular2}
    Log    The value of the embedded_argument: ${embedded_argument}
    Log Many    Values of the regulars    ${regular1}    ${regular2}

Item Assignment To List
    [Documentation]    Various ways of assigning list items
    ${list} =    Create List    one    two    three    four
    ${list}[0] =    Set Variable    first
    ${list}[${1}] =    Set Variable    second
    ${list}[2:3] =    Evaluate    ['third']
    ${list}[-1] =    Set Variable    last
    Should Be Equal As Strings    ${list}    ['first', 'second', 'third', 'last']

Item Assignment To Dictionary
    [Documentation]    Various ways of assigning dictionary items
    ${DICTIONARY} =    Create Dictionary    first_name=unknown
    ${DICTIONARY}[first_name] =    Set Variable    John
    ${DICTIONARY}[last_name] =    Set Variable    Doe
    Should Be Equal As Strings    ${DICTIONARY}    {'first_name': 'John', 'last_name': 'Doe'}
    Set Suite Variable    &{DICTIONARY}

# robocop: disable=0503
Different Ways Of Assigning Values With Flattened Keywords
    [Documentation]    Tryout different ways of assigning values to list and dictionary and flatten keywords
    [Tags]    robot:flatten
    ${list} =    Create List    one    two
    ${list}[0] =    Set Variable    new

    # Assign value using string index
    ${list}[1] =    Set Variable    value
    # Assign value using integer index
    ${list}[${0}] =    Set Variable    value
    # Assign value using variable as index
    ${other_variable} =    Set Variable    1
    ${list}[${other_variable}] =    Set Variable    value
    # Assign value using slice as index, i.e. assign by passing iterable values
    ${list}[1:-1] =    Evaluate    [1,2,3,4]
    Should Be Equal As Strings    ${list}    ['value', 1, 2, 3, 4, 'value']

    # Multiple variables assignments
    ${dictionary}[key]    ${list}[0]    @{list}[1] =    Evaluate    (1, 2, 3, 4, 5)

    Should Be Equal As Strings    ${list}    [2, [3, 4, 5], 2, 3, 4, 'value']
    Should Be Equal As Strings    ${dictionary}    {'first_name': 'John', 'last_name': 'Doe', 'key': 1}
