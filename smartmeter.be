var smartmeter = module()

import strict
import logger
import json

smartmeter.init = def(m)
    # Must be stateful to store data => use class instead of module, which is stateless
    class singleton
        var sm_data

        def init()
            self.sm_data = map()
        end

        def every_10_secs()
            # self.sm_data = {'V1': 239, 'P3o': 239, 'Ei': 45982.8, 'rEo': 21155.5, 'rEi': 8579.97, 
            #     'P2o': 167, 'P2i': 0, 'V2': 238, 'rPi': 0, 'Po': 0.632, 'P3i': 0, 
            #     'I2': 1.34, 'pf1': 0.56, 'P1o': 226, 'rPo': 768, 'P1i': 0, 'Pi': 0, 
            #     'SMid': 32942200, 'I3': 1.96, 'Eo': 34485.8, 'V3': 239, 'I1': 2.21}            
            var data = tasmota.read_sensors()
            if data != nil
                self.sm_data = json.load(data).find('z')
                logger.logMsg(logger.lDebug, f"Smartmeter data: {self.sm_data}")
            else
                logger.logMsg(logger.lWarn, f"No data. Check smartmeter configuration.")
            end
        end

        def start()
            tasmota.add_cron("*/10 * * * * *", /-> self.every_10_secs(), "every_10_s")
            logger.logMsg(logger.lInfo, "Smartmeter cronjob started")
        end

        def stop()
            tasmota.remove_cron("every_10_s")
            logger.logMsg(logger.lInfo, "Smartmeter cronjob stopped")
        end

        def get_data()
            return self.sm_data
        end

        def deinit()
            self.stop()
        end
    end

    # return a single instance for this class
    return singleton()
end

return smartmeter