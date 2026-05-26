@echo off
echo ====================================================
echo             DAO-CLI 授权码一键生成器 (v1.4.0)
echo ====================================================
echo.
set /p machine_id="请输入用户的设备机器特征码 (比如 M-8F3C-2A1B-E9D0): "
echo.
echo 正在为您进行高强度非对称签名计算...
echo.

:: 设置专属特权密钥以授权调用
set DAO_DEV_KEY=daozai_super_secret

:: 调用同目录或编译 release 目录下的 dao.exe 运行 keygen
if exist "%~dp0dao.exe" (
    "%~dp0dao.exe" keygen --machine "%machine_id%"
) else if exist "%~dp0vendor\DeepSeek-TUI\target\release\dao.exe" (
    "%~dp0vendor\DeepSeek-TUI\target\release\dao.exe" keygen --machine "%machine_id%"
) else (
    dao keygen --machine "%machine_id%"
)

echo.
pause
