local period = {}
period.__index = period

function period.create(duration, callback, ...)
    return setmetatable(
        {
            __duration=duration,
            __time=duration,
            __callback=callback,
            __args={...}
        },
        period
    )
end

function period:update(dt)
    self.__time = self.__time - dt
    if self.__time > 0 then return end

    self.__time = self.__time + self.__duration
    self.__callback(unpack(self.__args))
end


return {
    period=period.create
}
