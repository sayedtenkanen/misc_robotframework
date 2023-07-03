"""
Misc feature checking functions and methods to be used with Robot Framework
Prolly not the best practice to have module with both classes (and methods) and functions
And it also has a quirky name for fun :)
"""

from datetime import date
import re
from pathlib import Path
from typing import Any
from robot.api import logger
from robot.api.deco import keyword, library
from robot.running import TestSuite


@keyword(name="Call Independent Function From Module With Class")
def call_function_in_module_with_class() -> None:
    """
    Method in a module with classes
    """
    logger.info(f"Function name is {call_function_in_module_with_class.__name__}")


@keyword(
    name="Keyword With Integer Value ${int_value:\\d+} Float Value ${float_value:\\d*\\.\\d+|\\d+} And String ${string_value}"  # noqa: E501 pylint: disable=C0301
)
def keyword_int_value_float_string(
    int_value: int, float_value: float, string_value: str
) -> None:
    """
    Keyword that uses embedded arguments with regular expressions
    """
    logger.info(
        f"Integer value: {int_value}, "
        f"Float value: {float_value} and "
        f"String value: {string_value}"
    )


@keyword
def call_serialization_function(path: Path | str) -> dict:
    """Convert Robot testsuite to Python dictionary"""
    suite: TestSuite = TestSuite.from_file_system(path)
    suite_data: dict[str, Any] = suite.to_dict()
    logger.info(f"Serialized testsuite \n{suite_data= }")
    return suite_data


@keyword
def call_deserialization_function(path: dict) -> TestSuite:
    """Create testsuite from a given Python dictionary that was created from Robot testsuite"""
    suite: TestSuite = TestSuite.from_dict(path)
    return suite


class FiDate(date):
    """
    Custom type extends an existing type but that is not required (shown as example)
    Converter function implemented as a classmethod. It could be a normal
    function as well, but this way all code is in the same class.
    """

    @classmethod
    def from_string(cls, value: str) -> date:
        """
        Handles date given in the Finnish format
        """
        match: re.Match[str] | None = re.match(r"(\d{1,2})\.(\d{1,2})\.(\d{4})$", value)
        if not match:
            raise ValueError(f"Expected date in format 'dd.mm.yyyy', got '{value}'.")
        day, month, year = match.groups()
        return cls(int(year), int(month), int(day))


# Another custom type
class UsDate(date):
    """
    Converter function implemented as a classmethod. It could be a normal
    function as well, but this way all code is in the same class.
    """

    @classmethod
    def from_string(cls, value: str) -> date:
        """
        Handles date given in the US format
        """
        match = re.match(r"(\d{1,2})/(\d{1,2})/(\d{4})$", value)
        if not match:
            raise ValueError(f"Expected date in format 'mm/dd/yyyy', got '{value}'.")
        month, day, year = match.groups()
        return cls(int(year), int(month), int(day))


@library(converters={FiDate: FiDate.from_string, UsDate: UsDate.from_string})
class ConversionLibrary:
    """
    Uses custom converter supporting 'dd.mm.yyyy' format and others: US and ISO
    '@library' decorator is used to register converters
    """

    @keyword
    def finnish_format(self, arg: FiDate) -> None:
        """
        Prints the date given in the Finnish format
        Uses custom converter supporting 'dd.mm.yyyy' format
        """
        print(f"year: {arg.year}, month: {arg.month}, day: {arg.day}")

    @keyword
    def us_format(self, arg: UsDate) -> None:
        """
        Prints the date given in the Finnish format
        Uses custom converter supporting 'mm/dd/yyyy' format
        """
        print(f"year: {arg.year}, month: {arg.month}, day: {arg.day}")

    @keyword
    def iso_8601(self, arg: date) -> None:
        """
        Prints date given in the ISO 8601 format
        """
        print(f"year: {arg.year}, month: {arg.month}, day: {arg.day}")

    @keyword
    def any(self, arg: FiDate | UsDate | date) -> None:
        """
        Prints date in any of the given formats define here in the module
        """
        print(f"year: {arg.year}, month: {arg.month}, day: {arg.day}")
