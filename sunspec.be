var sunspec = module()
import strict
import logger

sunspec.init = def(m)
    class singleton
        var registers
        var working_dir

        def load_registers(working_dir)
            import json
            self.working_dir = working_dir
            var f = nil
            try
                f = open("user-mapping.json", "r")
                logger.logMsg(logger.lInfo, "File 'user-mapping.json' loaded")
            except .. as error
                f = open(working_dir + "sunspec.json", "r")
                logger.logMsg(logger.lInfo, "File 'sunspec.json' loaded")
            end
            var js = f.read()
            self.registers = json.load(js)
            f.close()
        end

        def get_registers() 
            return self.registers
        end

        def reload()
            self.load_registers(self.working_dir)
        end
    end

    return singleton()
end

return sunspec