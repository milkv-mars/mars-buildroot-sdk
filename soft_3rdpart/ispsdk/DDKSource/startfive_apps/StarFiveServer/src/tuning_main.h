/**
  ******************************************************************************
  * @file tuning_main.h
  * @author  StarFive Isp Team
  * @version  V1.0
  * @date  06/21/2022
  * @brief StarFive ISP tuning server tuning application header
  ******************************************************************************
  * @copy
  *
  * THE PRESENT FIRMWARE WHICH IS FOR GUIDANCE ONLY AIMS AT PROVIDING CUSTOMERS
  * WITH CODING INFORMATION REGARDING THEIR PRODUCTS IN ORDER FOR THEM TO SAVE
  * TIME. AS A RESULT, STARFIVE SHALL NOT BE HELD LIABLE FOR ANY
  * DIRECT, INDIRECT OR CONSEQUENTIAL DAMAGES WITH RESPECT TO ANY CLAIMS ARISING
  * FROM THE CONTENT OF SUCH FIRMWARE AND/OR THE USE MADE BY CUSTOMERS OF THE
  * CODING INFORMATION CONTAINED HEREIN IN CONNECTION WITH THEIR PRODUCTS.
  *
  * Copyright (C)  2019 - 2022 StarFive Technology Co., Ltd.
  */

#ifndef __TUNING_MAIN_H__
#define __TUNING_MAIN_H__

#include <stdint.h>
#include "comm.h"
#include "tuning_base.h"

#define TUNING_SERVER_NAME					"StarFive Tuning Server"
#define TUNING_SERVER_VERSION				0x00010003
#define TUNING_SERVER_PORT					8550
#define TUNING_SERVER_MAX_CONNECTION		10


extern BOOL g_tuning_debug_enable;


int tuning_main_listen_task(void* pparameters);
int tuning_main_connection_task(void* pparameters);
int32_t tuning_main_porcess_data(SOCKET sock, STCOMDDATA* pcomddata);
int32_t tuning_main_parse_command(SOCKET sock, STCOMDDATA* pcomddata);
int32_t tuning_main_parse_general_command(SOCKET sock, STCOMDDATA* pcomddata);
int32_t tuning_main_parse_isp_command(SOCKET sock, STCOMDDATA* pcomddata);
int32_t tuning_main_get_general_command(SOCKET sock, STCOMDDATA* pcomddata);
int32_t tuning_main_set_general_command(SOCKET sock, STCOMDDATA* pcomddata);

#endif //__TUNING_MAIN_H__

