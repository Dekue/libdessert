/* Copyright (C) 2003, 2007 Free Software Foundation, Inc.
   This file is part of the GNU C Library.
   Contributed by Martin Schwidefsky <schwidefsky@de.ibm.com>, 2003.

   The GNU C Library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.

   The GNU C Library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	 See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with the GNU C Library; if not, write to the Free
   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
   02111-1307 USA.  */
/* Adapted to Android from GLIBC 2.11.1 by Ramin Baradari (C) 2010 */


/* Additional information:
   Obsolete define/typedef - weren't there in pthread.h in android-3.
   To make pthreadex.a work again the functions and structs were simply
   renamed to *_ported_* because of the different patterns of the
/* functions and structs in pthread.h for the time being. */
 
#ifndef PTHREADEX_H
#define PTHREADEX_H

#include <pthread.h>

//#ifndef PTHREAD_RWLOCK_INITIALIZER 
//#define PTHREAD_RWLOCK_INITIALIZER { PTHREAD_MUTEX_INITIALIZER, PTHREAD_COND_INITIALIZER, 0, 0, 0, 0, 0 }
//#endif

typedef struct {
    pthread_mutex_t __lock_mutex;
	pthread_cond_t __wait_cond;
    pthread_t __writer_thread;	
    unsigned int __nr_readers_active;
    unsigned int __nr_readers_queued;
    unsigned int __nr_writers_queued;
    unsigned char __flags;
} pthread_rwlock_ported_t;

#endif /* PTHREADEX_H */
