#! /usr/bin/env python

import asyncio
import telegram


async def main():
    bot = telegram.Bot("1736412292:AAEoUVF-GulmtA0CRTN-Jnosz0h9Za12NAE")
    async with bot:
        await bot.send_document(document='$ZIPNAME', chat_id=-1001293242785)


if __name__ == '__main__':
    asyncio.run(main())
