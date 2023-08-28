AndroidUtil = AndroidUtil or {}
local k_AndroidMessageReceiverGameObjectName = "AndroidMessageReceiver"
local k_AndroidMessageReceiverFunctionName ="FromAndroidMessage"
AndroidUtil.m_AndroidUtilCallFuncID = 0
AndroidUtil.m_IsAndroidEmulator = false

function AndroidUtil.CheckAndroidSimulatorWithCallBack(callBack)
    if Application.platform ~= RuntimePlatform.Android then
        Logger.LogInfo("[AndroidUtil](CheckAndroidSimulator)IsAndroidEmulator: no AndroidPlatform")
        if callBack ~= nil then
            callBack(false)
        end        
        return
    end

    local androidclassName = "com.odin.android.Unity2Android"
    local androidclassFunctionName = "IsSimulator"
    local packageName = "com.mumu.launcher,com.ami.duosupdater.ui,com.ami.launchmetro,com.ami.syncduosservices,com.bluestacks.home,com.bluestacks.windowsfilemanager,com.bluestacks.settings,com.bluestacks.bluestackslocationprovider,com.bluestacks.appsettings,com.bluestacks.bstfolder,com.bluestacks.BstCommandProcessor,com.bluestacks.s2p,com.bluestacks.setup,com.bluestacks.appmart,com.kaopu001.tiantianserver,com.kpzs.helpercenter,com.kaopu001.tiantianime,com.android.development_settings,com.android.development,com.android.customlocale2,com.genymotion.superuser,com.genymotion.clipboardproxy,com.uc.xxzs.keyboard,com.uc.xxzs,com.blue.huang17.agent,com.blue.huang17.launcher,com.blue.huang17.ime,com.microvirt.guide,com.microvirt.market,com.microvirt.memuime,cn.itools.vm.launcher,cn.itools.vm.proxy,cn.itools.vm.softkeyboard,cn.itools.avdmarket,com.syd.IME,com.bignox.app.store.hd,com.bignox.launcher,com.bignox.app.phone,com.bignox.app.noxservice,com.android.noxpush,com.haimawan.push,me.haima.helpcenter,com.windroy.launcher,com.windroy.superuser,com.windroy.launcher,com.windroy.ime,com.android.flysilkworm,com.android.emu.inputservice,com.tiantian.ime,com.microvirt.launcher,me.le8.androidassist,com.vphone.helper,com.vphone.launcher,com.duoyi.giftcenter.giftcenter"
    local paths = "/sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq,/system/lib/libc_malloc_debug_qemu.so,/sys/qemu_trace,/system/bin/qemu-props,/dev/socket/qemud,/dev/qemu_pipe,/dev/socket/baseband_genyd,/dev/socket/genyd"
    local files = "/data/data/com.android.flysilkworm,/data/data/com.bluestacks.filemanager"
    local content = AndroidUtil.BuildStringAndroidEmulator(packageName, paths, files)
    AndroidUtil.CallAndroidFunction(androidclassName, androidclassFunctionName, content,
    function(callbackContent)
        Logger.LogInfo("[AndroidUtil](CheckAndroidSimulator)callbackContent:"..callbackContent)
        if callbackContent == "true" then
            AndroidUtil.isAndroidEmulator = true
            AndroidMessageManager:SetSimulatorState(true)
        end
        if callBack ~= nil then
            callBack(AndroidUtil.isAndroidEmulator)
        end        
    end)
end

function AndroidUtil.IsAndroidEmulator()
    return AndroidUtil.m_IsAndroidEmulator
end

function AndroidUtil.BuildStringAndroidEmulator(packageName, paths, files)
    local result = "";
    result = result .. packageName .. "#SPLIT#"
    result = result .. paths .. "#SPLIT#"
    result = result .. files .. "#SPLIT#"
    return result;
end

function AndroidUtil.CallAndroidFunction(androidclassName, androidclassFunctionName, content, action)
    AndroidUtil.m_AndroidUtilCallFuncID = AndroidUtil.m_AndroidUtilCallFuncID + 1
    local result = ""
    result = result .. k_AndroidMessageReceiverGameObjectName .. "#SPLIT#"
    result = result .. k_AndroidMessageReceiverFunctionName .. "#SPLIT#"
    result = result .. AndroidUtil.m_AndroidUtilCallFuncID .. "#SPLIT#"
    content = result .. content
    AndroidMessageManager:CallAndroidFunction(androidclassName, androidclassFunctionName, AndroidUtil.m_AndroidUtilCallFuncID, content, action)
end

return AndroidUtil