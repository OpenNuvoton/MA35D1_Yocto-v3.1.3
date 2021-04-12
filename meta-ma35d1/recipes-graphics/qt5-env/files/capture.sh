gst-launch-1.0 v4l2src num-buffers=1 device=/dev/video0 ! jpegenc ! filesink location=$1
