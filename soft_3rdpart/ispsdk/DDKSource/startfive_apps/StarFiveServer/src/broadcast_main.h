/**
  ******************************************************************************
  * @file broadcast_main.h
  * @author  StarFive Isp Team
  * @version  V1.0
  * @date  06/21/2022
  * @brief StarFive ISP tuning server broadcast header file
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

#ifndef __BROADCAST_MAIN_H__
#define __BROADCAST_MAIN_H__

#define BROADCAST_SERVER_NAME					"StarFive Broadcast Server"
#define BROADCAST_SERVER_VERSION				0x00010000
#define BROADCAST_SERVER_PORT					22233
#define BROADCAST_BUFFER_LEN					512

typedef enum
{
	BRCMD_NULL = 0,
	BRCMD_GET_ALL,
	BRCMD_GET_TUNING,
	BRCMD_GET_STREAM,
	BRCMD_GET_RTSP,
	BRCMD_BYE
} BRCMD;

int broadcast_main_listen_task(void* pparameters);
int broadcast_main_get_adapter_ip(char* pbuf, uint32_t buflen, int method);
BOOL broadcast_main_get_host_ip(char* pbuf, uint32_t buflen);
void broadcast_main_generate_all_buf(int command, char* pszip, char* pbuf, uint32_t buflen);
void broadcast_main_generate_tuning_buf(char* pszip, char* pbuf, uint32_t buflen);
void broadcast_main_generate_rtsp_buf(char* pszip, char* pbuf, uint32_t buflen);
int broadcast_main_parse_recvbuf(char* pbuf, int* pPort);

#endif //__BROADCAST_MAIN_H__