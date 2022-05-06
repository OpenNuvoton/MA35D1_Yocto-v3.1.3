gst-launch-1.0 v4l2src num-buffers=1 device=/dev/video0 ! jpegenc ! filesink location=$1
# gst-launch-1.0 v4l2src device=/dev/video1 ! videoscale ! 'video/x-raw,width=1024,height=600,framerate=30/1' ! videoconvert ! fbdevsink device=/dev/fb0 sync=false
