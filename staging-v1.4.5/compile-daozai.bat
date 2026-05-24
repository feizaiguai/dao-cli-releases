@echo off
echo ====================================================
echo             DAO-CLI 刀仔专属特权版 一键编译系统
echo ====================================================
echo.
echo 正在为您配置特权环境变量并准备编译...
set DAO_DEV_KEY=daozai_super_secret

:: 切换到批处理所在目录下的 DeepSeek-TUI
cd /d "%~dp0vendor\DeepSeek-TUI"

echo.
echo [1/2] 正在编译运行时二进制 (dao-cli)...
cargo build --release --package dao-cli-runtime --bin dao-cli
if %errorlevel% neq 0 (
    echo.
    echo ? [错误] 编译 dao-cli 失败，请检查 Rust 或 Cargo 环境！
    pause
    exit /b %errorlevel%
)

echo.
echo [2/2] 正在编译分发器二进制 (dao)...
cargo build --release --package dao-cli-dispatcher --bin dao
if %errorlevel% neq 0 (
    echo.
    echo ? [错误] 编译 dao 失败，请检查 Rust 或 Cargo 环境！
    pause
    exit /b %errorlevel%
)

echo.
echo ====================================================
echo ?? 恭喜！专属特权版二进制已全自动 100%% 成功编译！
echo.
echo 编译出的新二进制软件位置：
echo ? D:\DAO-CLI\vendor\DeepSeek-TUI\target\release\dao.exe
echo ? D:\DAO-CLI\vendor\DeepSeek-TUI\target\release\dao-cli.exe
echo ====================================================
echo.
pause
