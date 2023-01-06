################################################################################
#
# v4l2_dec_test
#
################################################################################

V4L2_DEC_TEST_LICENSE = GPL-2.0+

define V4L2_DEC_TEST_BUILD_CMDS
	cp package/starfive/v4l2_dec_test/v4l2_dec_test.c $(@D)/
	(cd $(@D); $(TARGET_CC) -Wall v4l2_dec_test.c -lv4l2 \
			-ldl -lpthread -Wl,--fatal-warning \
			-lavformat -lavcodec -lavutil -lswresample \
			-o v4l2_dec_test)
endef

define V4L2_DEC_TEST_INSTALL_TARGET_CMDS
	$(INSTALL) -m 0777 $(@D)/v4l2_dec_test $(TARGET_DIR)/root/v4l2_dec_test
endef

V4L2_DEC_TEST_DEPENDENCIES = ffmpeg libv4l
$(eval $(generic-package))

