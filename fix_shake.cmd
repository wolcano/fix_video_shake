@echo off
setlocal enabledelayedexpansion

:: Removes camera shake
:: Drop files onto this CMD


:LOOPSTART
	set INFILE=%1
	echo Processing file !INFILE!

	if not exist !INFILE! (
		goto LOOPCHECK
	)
	
	:: VIDEOFILTER VIDSTAB
	echo Analysing video
	FOR /F "usebackq delims==" %%i IN (`echo !INFILE!`) DO set INFILE_NAME=%%~nxi
	ffmpeg -hide_banner -i !INFILE! -acodec copy -vf vidstabdetect=stepsize=32:shakiness=8:accuracy=9:result="!INFILE_NAME!.trf" -f null -
	
	echo Stabilising video
	ffmpeg -hide_banner -i !INFILE! -vf vidstabtransform=input="!INFILE_NAME!.trf":zoom=1:smoothing=30 -vcodec libx264 -acodec copy !INFILE!.mkv
	:: optzoom=0  -- doesnt remove black surrounding frame
	
	::: VIDEOFILTER DESHAKE - very slow with inferior results
	::ffmpeg -i !INFILE! -acodec copy -cpuflags -sse2 -vf deshake=rx=64:ry=64 !INFILE!.mkv

	:LOOPCHECK
	shift
	if x%1==x GOTO LOOPEXIT
	goto LOOPSTART
:LOOPEXIT

pause
