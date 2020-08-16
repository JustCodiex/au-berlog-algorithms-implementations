return {
    _internal_container = {},
    _ptr = 0,
    push = function(self, obj)
        self._ptr = self._ptr + 1;
        self._internal_container[self._ptr] = obj;
    end,
    pop = function(self, obj)
        local val = self._internal_container[self._ptr];
        self._ptr = self._ptr - 1;
        return val;
    end,
    peek = function(self)
        return self._internal_container[self._ptr];
    end,
    size = function(self)
        return self._ptr;
    end,
    clone = function(self)
        local _copy_t = {};
        for i=1, self._ptr do
            _copy_t[i] = self._internal_container[i];
        end
        return _copy_t;
    end,
};
