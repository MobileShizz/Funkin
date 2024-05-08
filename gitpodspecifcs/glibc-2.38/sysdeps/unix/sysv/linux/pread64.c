/* Copyright (C) 1997-2023 Free Software Foundation, Inc.
   This file is part of the GNU C Library.

   The GNU C Library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.

   The GNU C Library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with the GNU C Library; if not, see
   <https://www.gnu.org/licenses/>.  */

#include <unistd.h>
#include <sysdep-cancel.h>
#include <shlib-compat.h>

ssize_t
__libc_pread64 (int fd, void *buf, size_t count, off64_t offset)
{
  return SYSCALL_CANCEL (pread64, fd, buf, count, SYSCALL_LL64_PRW (offset));
}

weak_alias (__libc_pread64, __pread64)
libc_hidden_weak (__pread64)
weak_alias (__libc_pread64, pread64)

#ifdef __OFF_T_MATCHES_OFF64_T
strong_alias (__libc_pread64, __libc_pread)
weak_alias (__libc_pread64, __pread)
weak_alias (__libc_pread64, pread)

# if OTHER_SHLIB_COMPAT (libpthread, GLIBC_2_1, GLIBC_2_2)
compat_symbol (libc, __libc_pread64, pread, GLIBC_2_2);
# endif
#endif

#if OTHER_SHLIB_COMPAT (libpthread, GLIBC_2_1, GLIBC_2_2)
compat_symbol (libc, __libc_pread64, pread64, GLIBC_2_2);
compat_symbol (libc, __libc_pread64, __pread64, GLIBC_2_2);
#endif
