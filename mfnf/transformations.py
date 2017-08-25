"""Module with utilities for transformations of JSON trees."""

import inspect
import json
import os

from abc import ABCMeta, abstractmethod
from collections import OrderedDict
from collections.abc import Sequence, Mapping
from mfnf.utils import lookup

class NotInterested(Exception):
    pass

class check:
    def __init__(self, *args):
        self._res = lookup(*args)
    def __eq__(self, other):
        if not self._res == other:
            raise NotInterested()
    def of(self, *others):
        if not self._res in others:
            raise NotInterested()

class Action(metaclass=ABCMeta):
    """Base class for an action."""

    def __init__(self, **options):
        for key, value in options.items():
            setattr(self, key, value)

    @abstractmethod
    def __call__(self, arg):
        """Defines a transformation on the argument `arg`."""
        raise NotImplementedError

class ChainedActionMetaclass(ABCMeta):
    """Metaclass for class `ChainedTransformations` which add the member
    `actions` with the list of all transformations defined inside the class
    definition."""

    @classmethod
    def __prepare__(mcs, name, bases):
        return OrderedDict(super().__prepare__(mcs, name, bases))

    def __new__(mcs, name, bases, props):
        props["action_classes"] = [x for x in props.values() \
                                     if inspect.isclass(x)]

        return type.__new__(mcs, name, bases, dict(props))

class ChainedAction(Action, metaclass=ChainedActionMetaclass):
    """A transformation which combines all transformations which are defined
    inside this class."""

    action_classes = []

    def __init__(self, **options):
        super().__init__(**options)

        self.actions = [x(**options) for x in self.action_classes]
        self.step_number = 1

    def __call__(self, arg):
        result = arg

        for action in self.actions:
            result = action(result)

            if __debug__:
                self.log_current_result(action, result)

        return result

    def log_current_result(self, action, result):
        # This code shall not be here! In future versions there need to be
        # a better solution. :-)

        fmt = "/tmp/mfnf-log/{}-{:03d}-after-{}.json"
        file_name = fmt.format(self.__class__.__name__, self.step_number,
                               action.__class__.__name__)
        self.step_number += 1

        try:
            os.mkdir(os.path.dirname(file_name))
        except FileExistsError:
            pass

        with open(file_name, "w") as fd:
            fd.write(json.dumps(result, indent=1))

class Transformation(Action):
    """Base class of a transformation of a JSON object. This class implements
    the identity transformation. It returns a new copy of the given JSON
    object."""

    def act_on_dict(self, obj):
        """Transforms the dictionary `obj`."""
        return {k:v for k, v in ((x, self(y)) for x, y in obj.items()) \
                if v != None}

    def act_on_list(self, lst):
        """Transforms the list `lst`."""
        return [y for y in (self(x) for x in lst) if y != None]

    def __call__(self, obj):
        """Transforms the JSON object `obj`."""
        if isinstance(obj, str):
            return obj
        elif isinstance(obj, Sequence):
            return self.act_on_list(obj)
        elif isinstance(obj, Mapping):
            return self.act_on_dict(obj)
        else:
            return obj

class NodeTransformation(Transformation):
    """Transformations which acts on certain dictionaries."""

    @abstractmethod
    def transform_dict(self, obj):
        """Computes new dictionary which shall be used in tree instead of the
        node `obj`."""
        raise NotImplementedError

    def act_on_dict(self, obj):
        try:
            return self.transform_dict(obj)
        except NotInterested:
            return super().act_on_dict(obj)

class NodeTypeTransformation(NodeTransformation):
    """Transformation based on the attribute `"type"` of the node
    dictionary."""

    def transform_dict(self, obj):
        if not "type" in obj:
            raise NotInterested()
        try:
            return getattr(self, "transform_" + obj["type"])(obj)
        except AttributeError:
            return self.default_transformation(obj)

    def default_transformation(self, obj):
        """Default transformation for the case no suitable transformation was
        found."""
        raise NotInterested()
