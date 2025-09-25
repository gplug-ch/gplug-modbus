var logger = module()

import string

logger.lOff   = 0
logger.lInfo  = 1
logger.lWarn  = 2
logger.lDebug = 3
logger.lMore  = 4

var level = 3     # range from 0 (Off) .. 5  (More)
var hexShort = 0
var hexFull  = 1
var ASCII    = 2
var chunkFormat = 0   # range from 0 ... 2

logger.hexShort = def(aBB)
    var len = 5
    if aBB.size() <= (3+2*len)
        return aBB.tohex()
    else
        return aBB[0 .. 4].tohex() + "..." + aBB[-5 .. ].tohex()
    end
end

logger.setLevel = def(aTrLev)
    assert( (aTrLev >= logger.lOff && aTrLev <= logger.lMore),
        "setLevel(aTrLev) out of range: " + str(aTrLev))
    level = aTrLev
end

logger.logMsg = def(aTrLev, aMsg)
    if level < aTrLev 
        return
    end
    print(aMsg)
end

return logger