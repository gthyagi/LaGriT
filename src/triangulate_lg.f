      subroutine triangulate_lg(imsgin,xmsgin,cmsgin,msgtype,nwds,
     *      ierror)
C
C
C #####################################################################
C
C     PURPOSE -
C
C   TRIANGULATE triangulates the interior of a polygon described
C    by the ordered nodes in a 2d mesh
C
C     INPUT ARGUMENTS -
C
C         none
C
C     OUTPUT ARGUMENTS -
C
C         ierror - Error Return Code (==0 ==> OK, <>0 ==> Error)
C     FORMAT:
c         triangulate/[clockwise|counterclockwise]
C
C     CHANGE HISTORY -
C
C$Log: triangulate_lg.f,v $
CRevision 2.00  2007/11/09 20:04:05  spchu
CImport to CVS
C
CPVCS    
CPVCS       Rev 1.4   22 Mar 2000 08:32:58   dcg
CPVCS    replace epsilon with local_eps
CPVCS
CPVCS       Rev 1.3   Fri Jul 09 14:40:40 1999   dcg
CPVCS    add another check to avoid infinite loops
CPVCS
CPVCS       Rev 1.2   Fri Jul 09 11:41:02 1999   dcg
CPVCS    check that last point is not the same as first point
CPVCS
CPVCS       Rev 1.1   Fri Jul 09 10:24:20 1999   dcg
CPVCS    allow for clockwise/counterclockwise choice
CPVCS    check and prevent infinite loop
CPVCS
CPVCS       Rev 1.0   Wed Jan 06 15:08:04 1999   dcg
CPVCS    Initial revision.
C #####################################################################
      implicit none
C
      include 'local_element.h'

c  arguments
      integer nwds, imsgin(nwds), msgtype(nwds)
      real*8 xmsgin(nwds)
      character*(*) cmsgin(nwds)
      integer ierror

c variables

      pointer (ipimt1, imt1)
      pointer (ipitetoff, itetoff)
      pointer (ipitettyp, itettyp)
      pointer (ipitet, itet)
      pointer (ipjtet,jtet)
      pointer (ipjtetoff,jtetoff)

      integer imt1(*)
      integer itetoff(*)
      integer itettyp(*)
      integer itet(3,*)
      integer jtet(*)
      integer jtetoff(*)

      pointer (ipxic, xic)
      pointer (ipyic, yic)
      pointer (ipzic, zic)
      real*8 xic(*)
      real*8 yic(*)
      real*8 zic(*)

      integer nnodes,length,icmotype,icscode,nsd_topo,
     *   ifirstpt,nelts,nelements,it,nlast

      logical isccw

      character*132 logmess
      character*32 cmo,isubname
      character*132 cmd
c
c begin

c  Get orientation of nodes
c 
      isccw=.false.
      if(nwds.ge.2.and.cmsgin(2)(1:8).eq.'counterc') isccw=.true.
c
C  Check that user has specified a valid mesh object.
c 
      call cmo_get_name(cmo,ierror)
      if(ierror.ne.0) then
         write(logmess,'(a)')'ERROR: '
         call writloga('default',0,logmess,0,icscode)
         write(logmess,'(a,a,a)')
     *      'TRIANGULATE: ',cmo,' does not exist'
         call writloga('default',0,logmess,0,icscode)
         goto 9999
      endif
      call cmo_get_info('nnodes',cmo,
     *   nnodes,length,icmotype,icscode)
      if (icscode .ne. 0) call x3d_error(isubname,'cmo_get_info')
      call cmo_get_info('ndimensions_topo',cmo,
     *   nsd_topo,length,icmotype,icscode)
      call cmo_get_info('nelements',cmo,
     *   nelements,length,icmotype,icscode)
      if (icscode .ne. 0) call x3d_error(isubname,'cmo_get_info')
      if (icscode .ne. 0) call x3d_error(isubname,'cmo_get_info')
      if (nsd_topo.ne.2) then
         write(logmess,'(a,a,a)')
     *      'TRIANGULATE: ',cmo,' not a valid 2d mesh object'
         call writloga('default',0,logmess,0,icscode)
          write(logmess,'(a,i4,a)')
     *      'TRIANGULATE: ',nsd_topo,' nsd_topo dimension topology'
         call writloga('default',0,logmess,0,icscode)
        ierror=1
         goto 9999
      endif
c
c  access mesh object data
c 
      call cmo_get_info('xic',cmo,
     *   ipxic,length,icmotype,icscode)
      if (icscode .ne. 0) call x3d_error(isubname,'cmo_get_info')
      call cmo_get_info('yic',cmo,
     *   ipyic,length,icmotype,icscode)
      if (icscode .ne. 0) call x3d_error(isubname,'cmo_get_info')
c
c check if first point is the same as last point
c if so eliminate last point
c 
      ifirstpt=1
      nlast=nnodes
      if(xic(ifirstpt).eq.xic(nlast).and.
     *   yic(ifirstpt).eq.yic(nlast)) then
         nlast=nlast-1
          write(logmess,
     *     "('WARNING: first point is the same as last point')")
          call writloga('default',0,logmess,0,icscode)
          write(logmess,
     *     "('WARNING: eliminate last point')")
          call writloga('default',0,logmess,0,icscode)
      endif
c
c  make space for new triangles
c 
      nelements=nlast-2
      call cmo_set_info('nelements',cmo,nelements,1,1,icscode)
      if (icscode .ne. 0) call x3d_error(isubname,'cmo_get_info')
      call cmo_newlen(cmo,icscode)
      if (icscode .ne. 0) call x3d_error(isubname,'cmo_get_info')
      nelts=0
      call cmo_get_info('itet',cmo,
     *   ipitet,length,icmotype,icscode)
      if (icscode .ne. 0) call x3d_error(isubname,'cmo_get_info')
c----------------------------------------------------------------------
c  TRIANGULATE
c----------------------------------------------------------------------
      call maketriangles_lg (ifirstpt,nlast,xic,yic,nelts,
     *                       itet,isccw,ierror)
c----------------------------------------------------------------------
      if(ierror.ne.0) then
         nelts=0
         ierror=0
         if(isccw)then
            write(logmess,"('WARNING: triangulate')")
            call writloga('default',0,logmess,0,icscode)
            write(logmess,"('WARNING: Counterclockwise did not work')")
            call writloga('default',0,logmess,0,icscode)
            write(logmess,"('WARNING: Trying clockwise')")
            call writloga('default',0,logmess,0,icscode)
            isccw = .false.
            call maketriangles_lg (ifirstpt,nlast,xic,yic,nelts,
     *                             itet,isccw,ierror)
          else
            write(logmess,"('WARNING: triangulate')")
            call writloga('default',0,logmess,0,icscode)
            write(logmess,"('WARNING: Clockwise did not work')")
            call writloga('default',0,logmess,0,icscode)
            write(logmess,"('WARNING: Trying counterclockwise')")
            call writloga('default',0,logmess,0,icscode)
            isccw = .true.
            call maketriangles_lg (ifirstpt,nlast,xic,yic,nelts,
     *                             itet,isccw,ierror)
          endif
       endif

       if(ierror.ne.0) then
          write(logmess,"('ERROR: triangulate')")
          call writloga('default',0,logmess,0,icscode)
          write(logmess,"('ERROR: Unable to triangulate input')")
          call writloga('default',0,logmess,0,icscode)
          nelements=0
          call cmo_set_info('nelements',cmo,nelements,1,1,icscode)
          if (icscode .ne. 0) call x3d_error(isubname,'cmo_get_info')
          go to 9999
       endif
c
c  set itettyp and itetoff and jtetoff
c 
      call cmo_get_info('itetoff',cmo,
     *   ipitetoff,length,icmotype,icscode)
      if (icscode .ne. 0) call x3d_error(isubname,'cmo_get_info')
      call cmo_get_info('jtetoff',cmo,
     *   ipjtetoff,length,icmotype,icscode)
      if (icscode .ne. 0) call x3d_error(isubname,'cmo_get_info')
      call cmo_get_info('itettyp',cmo,
     *   ipitettyp,length,icmotype,icscode)
      if (icscode .ne. 0) call x3d_error(isubname,'cmo_get_info')
      do it=1,nelements
         itettyp(it)=ifelmtri
         itetoff(it)=(it-1)*3
         jtetoff(it)=(it-1)*3
      enddo

      write(logmess,'(a,i4)')
     *   'TRIANGULATE: Number of triangle cells = ',nelements
      call writloga('default',0,logmess,0,icscode)

      cmd = 'filter / 1,0,0;finish'
      call dotaskx3d(cmd,ierror)
      cmd = 'rmpoint / compress;finish'
      call dotaskx3d(cmd,ierror)
      cmd = 'resetpts / itp;finish'
      call dotaskx3d(cmd,ierror)
 9999 continue
      return
      end
c
      subroutine maketriangles_lg (ifirstpt,ilastpt,x,y,nelts,
     *  ielts,isccw,ierror)
c
c   This subroutine triangulates the interior of the polygon
c   outlined by the coordinates in the arrays x and y from the
c   x(ifirstpt),y(ifirstpt) to x(ilastpt), y(ilastpt).  The
c   connection from ilastpt to ifirstpt is assumed in order
c   to close the polygon. The boundary of the polygon is assumed
c   not to cross itself.  No checks are made.
c
c   The triangles are returned in ielts.  nelts on entry
c   is the index of the last existing triangle.  nelts on
c   exit is the index of the last created triangle.
c 
      implicit none

c  arguments
      integer ifirstpt,ilastpt,nelts,ierror
      integer ielts(3,*) 
      real*8 x(*),y(*)
      logical isccw
      integer, allocatable :: tmp_elts(:)

c variables
      integer npts,j,i,nptsave,iv1,iv2,iv3,inelts
      integer ip1,ip2,ip3,icscode

      real*8 local_eps

      logical isinteriordiagonal_lg,iscolinear_lg,found

      character*32 isubname
      character*128 logmess

      pointer (ipipts,ipts)
      integer ipts(*)

c ------------------------------------------------------- 
c begin

c      print*,"maketriangles_lg ------------------------"
c      print*,"ifirstpt,lastpt: ",ifirstpt,ilastpt
c      print*,"nelts,isccw,ierror: ",nelts,isccw,ierror

      ierror=0
      isubname='maketriangles'
      found=.false.
c
c  copy in original polygon
      npts=ilastpt-ifirstpt+1
      call mmgetblk('ipts',isubname,ipipts,npts,1,icscode)
      do i=1,npts
        ipts(i)=ifirstpt-1+i
      enddo
      nptsave=npts
      i=0

c     Special case handling for 3-node mesh
      if (npts == 3) then
        allocate(tmp_elts(3))
        call singletri_lg(tmp_elts,x(1),y(1),x(2),y(2),x(3),y(3),isccw)
        nelts = 1
        ielts(1,nelts) = tmp_elts(1)
        ielts(2,nelts) = tmp_elts(2)
        ielts(3,nelts) = tmp_elts(3)
        deallocate(tmp_elts)
        go to 9999
      endif

      local_eps=1.d-8

c
c  loop through edges and try to lop off ears
c 
 10   i=i+1
      if (i.gt.npts-2) then
          if(npts.le.3) go to 9999
          if(.not.found) then
            ierror=1
c	    write(logmess,"('error in nodes, check orientation')")
c            call writloga('default',0,logmess,0,icscode)
            go to 9999
          endif
          i=1
           found=.false.
      endif
      iv1=ipts(i)
      iv2=ipts(i+1)
      ip1=i
      ip2=i+1
      if(i.ne.npts-1) then
        iv3=ipts(i+2)
        ip3=i+2
      else
        iv3=ipts(1)
        ip3=1
      endif
      if(iscolinear_lg(x(iv1),y(iv1),x(iv2),y(iv2),x(iv3),
     *  y(iv3),local_eps)) go to 10

      if(isinteriordiagonal_lg(ip1,ip3,npts,x,y,ipts,isccw,local_eps))
     *    then
        found=.true.
        nelts=nelts+1
        ielts(1,nelts)=iv1
        ielts(2,nelts)=iv2
        ielts(3,nelts)=iv3

c check for orientation
        if(isccw) then
           ielts(2,nelts)=iv3
           ielts(3,nelts)=iv2
        endif
        npts=npts-1
 
        do j=i+1,npts
           ipts(j)=ipts(j+1)
        enddo
        if(npts.eq.3) then
            nelts=nelts+1
            ielts(1,nelts)=ipts(1)
            ielts(2,nelts)=ipts(2)
            ielts(3,nelts)=ipts(3)
c check for orientation
           if(isccw) then
              ielts(2,nelts)=ipts(3)
              ielts(3,nelts)=ipts(2)
           endif
           go to 9999
        endif
      endif
      go to 10
 9999 continue
      npts=nptsave
      call mmrelprt(isubname,icscode)
      return
      end

c  function area_tri
c  compute signed area of the triangle
c  positive if points 1,2,3 are oriented counter clockwise
      function area_tri(x1,y1,x2,y2,x3,y3)
      implicit none
      real*8 x1,y1,x2,y2,x3,y3,area_tri
      area_tri=x1*y2-y1*x2+y1*x3-x1*y3+x2*y3-x3*y2
      return
      end

c  function isleft_lg
c  true if point 1 is to the left of line segment 2to3
      function isleft_lg(x1,y1,x2,y2,x3,y3)
      implicit none
      logical isleft_lg
      real*8 x1,y1,x2,y2,x3,y3,area_tri
      isleft_lg =.false.
      if (area_tri(x2,y2,x3,y3,x1,y1).gt.0.0 ) isleft_lg=.true.
      return
      end


      subroutine singletri_lg(tri,x1,y1,x2,y2,x3,y3,isccw)
c      returns clockwise or counter clockwise triangle
c      should be used in the edge case of 3 node mesh
c      Return value stored in 'tri' array

      implicit none
      real*8 x1,y1,x2,y2,x3,y3,midx,midy,mid(3)
      integer :: tri(3),tmp(1)
      logical isccw
      integer ix

c     Find midpoint of triangle
      midx = (x1+x2+x3)/3.
      midy = (y1+y2+y3)/3.

c     Find angle of nodes to midpoint
      mid = (/atan2(midy-y1,midx-x1),
     *        atan2(midy-y2,midx-x2),
     *        atan2(midy-y3,midx-x3)/)

c     Order nodes by angle
      tri(2) = -1
      tmp = minloc(mid)
      tri(1) = tmp(1)
      tmp = maxloc(mid)
      tri(3) = tmp(1)

      do ix = 1, size(mid)
        if (ix /= tri(1) .and. ix /= tri(3)) tri(2) = ix
      end do

c     Switch the second and third node pointer if counterclockwise
      if (isccw) then
        tmp(1) = tri(2)
        tri(2) = tri(3)
        tri(3) = tmp(1)
      endif
      
      end subroutine singletri_lg

c  function isleftoron_lg
c  true if point 1 is to the left of or on line segment 2to3

      function isleftoron_lg(x1,y1,x2,y2,x3,y3,isccw,local_eps)
      implicit none
      logical isleftoron_lg,isccw
      real*8 x1,y1,x2,y2,x3,y3,area_tri,local_eps

      isleftoron_lg =.false.

      if(isccw) then
        if (area_tri(x1,y1,x2,y2,x3,y3).gt.-local_eps )
     *    isleftoron_lg=.true.
      else
        if (area_tri(x1,y1,x3,y3,x2,y2).gt.-local_eps )
     *    isleftoron_lg=.true.
      endif
      return
      end

c function iscolinear_lg
c  return true if points 1,2,3 are iscolinear
      function iscolinear_lg(x1,y1,x2,y2,x3,y3,local_eps)
      implicit none
      logical iscolinear_lg
      real*8 x1,y1,x2,y2,x3,y3,area_tri,local_eps
      iscolinear_lg=.false.
      if (abs(area_tri(x1,y1,x2,y2,x3,y3)).lt.local_eps )
     *    iscolinear_lg=.true.
      return
      end

c function isintersect_lg
c  return true if line segment 1 to 2 intersects line segment 3 to 4
      function isintersect_lg(x1,y1,x2,y2,x3,y3,x4,y4,local_eps)
      implicit none
      logical isintersect_lg,iscolinear_lg,isleft_lg
      real*8 x1,y1,x2,y2,x3,y3,x4,y4,local_eps
      isintersect_lg=.false.
      if (iscolinear_lg(x1,y1,x2,y2,x3,y3,local_eps).or.
     *    iscolinear_lg(x1,y1,x2,y2,x4,y4,local_eps).or.
     *    iscolinear_lg(x1,y1,x3,y3,x4,y4,local_eps).or.
     *    iscolinear_lg(x2,y2,x3,y3,x4,y4,local_eps)) return
      if ((isleft_lg(x1,y1,x3,y3,x4,y4).neqv.
     *    isleft_lg(x2,y2,x3,y3,x4,y4))
     *    .and.
     *    (isleft_lg(x3,y3,x1,y1,x2,y2).neqv.
     *     isleft_lg(x4,y4,x1,y1,x2,y2)))
     *   isintersect_lg=.true.
      return
      end

c function isbetween_lg
c  return true if point 1 lies on the line between 2 and 3
      function isbetween_lg(x1,y1,x2,y2,x3,y3,local_eps)
      implicit none
      logical isbetween_lg,iscolinear_lg
      real*8 x1,y1,x2,y2,x3,y3,local_eps
      isbetween_lg=.false.
      if (iscolinear_lg(x1,y1,x2,y2,x3,y3,local_eps)) then
        if ((x1.ge.min(x2,x3)-local_eps.and.x1.le.max(x2,x3)+local_eps)
     *     .and.
     *     (y1.ge.min(y2,y3)-local_eps.and.y1.le.max(y2,y3)+local_eps))
     *  isbetween_lg=.true.
      endif
      return
      end

c function isintersectortee_lg
c  return true is line 1to2 intersect 3to4 or if the endpoint
c  of one line is on the other line
      function isintersectortee_lg(x1,y1,x2,y2,x3,y3,x4,y4,local_eps)
      implicit none
      logical isintersectortee_lg,isbetween_lg,isintersect_lg
      logical p13,p14,p23,p24,issamepoint_lg
      real*8 x1,y1,x2,y2,x3,y3,x4,y4,local_eps
      isintersectortee_lg=.false.
      p13 = .false.
      p14 = .false.
      p23 = .false.
      p24 = .false.
      p13 = issamepoint_lg(x1,y1,x3,y3,local_eps)
      p14 = issamepoint_lg(x1,y1,x4,y4,local_eps)
      p23 = issamepoint_lg(x2,y2,x3,y3,local_eps)
      p24 = issamepoint_lg(x2,y2,x4,y4,local_eps)
      if(p13.or.p14.or.p23.or.p24) then
c        isintersectortee_lg=.true.
         return
      endif
      if(isintersect_lg(x1,y1,x2,y2,x3,y3,x4,y4,local_eps))then
        isintersectortee_lg=.true.
      else
        if (isbetween_lg(x1,y1,x3,y3,x4,y4,local_eps) .or.
     *      isbetween_lg(x2,y2,x3,y3,x4,y4,local_eps) .or.
     *      isbetween_lg(x3,y3,x1,y1,x2,y2,local_eps) .or.
     *      isbetween_lg(x4,y4,x1,y1,x2,y2,local_eps))
     *         isintersectortee_lg=.true.
      endif
      return
      end

c function isinpoly_lg
c  return true if the diagonal from node i to node j is inside
c  the polygon
      function isinpoly_lg(i,j,npts,x,y,ipts,isccw,local_eps)
      implicit none
      integer i,j,npts,ipi,ipj,ipp1,ipm1
      integer ipts(*)
      real*8 x(*),y(*)
      real*8  local_eps
      logical isinpoly_lg,isleftoron_lg,isccw

c begin
      isinpoly_lg=.false.
      ipi=ipts(i)
      ipj=ipts(j)
      if(i.gt.npts) then
         ipp1=ipts(1)
      else
         ipp1=ipts(i+1)
      endif
      if(i.eq.1) then
         ipm1=ipts(npts)
      else
         ipm1=ipts(i-1)
      endif
c  two case for convex or reflex vertices
c  convex case
c  vertex i-1 must be to the left of diagonal ij and
c  vertex i+1 must be to the left of diagonal ji
      if(isleftoron_lg(x(ipp1),y(ipp1),x(ipm1),y(ipm1),x(ipi),y(ipi)
     *      ,isccw,local_eps))
     *    then
       if((isleftoron_lg(x(ipp1),y(ipp1),x(ipj),y(ipj),x(ipi),y(ipi)
     *      ,isccw,local_eps))
     *    .and.
     *  (isleftoron_lg(x(ipm1),y(ipm1),x(ipi),y(ipi),x(ipj),y(ipj)
     *      ,isccw,local_eps)))
     *    isinpoly_lg=.true.
      else

c  reflex case
c  diagonal must not be in the convex region -- therefore
c  it must be not true that vertex i-1 is left of ij and
c  vertex i+1 left of ji
         if(.not.
     *    (
     *    (isleftoron_lg(x(ipm1),y(ipm1),x(ipj),y(ipj),x(ipi),y(ipi)
     *      ,isccw,local_eps))
     *     .and.
     *    (isleftoron_lg(x(ipp1),y(ipp1),x(ipi),y(ipi),x(ipj),y(ipj)
     *      ,isccw,local_eps))
     *    )
     *      )
     *    isinpoly_lg=.true.
      endif
      return
      end

c function isinteriordiagonal_lg
c  return true if diagonal ij is an interior diagonal of the polygon
      function isinteriordiagonal_lg(i,j,npts,x,y,ipts,isccw,local_eps)
      implicit none
      integer i,j,npts,it
      integer ipts(*)
      real*8  local_eps,x1,y1,x2,y2,x3,y3,x_leaf,y_leaf
      real*8 x(*),y(*)

      logical isinteriordiagonal_lg,isdiagonal_lg,isinpoly_lg,isccw,
     *   dup_point, point_on_same_side, t_lf, isleftoron_lg,
     *   issamepoint_lg, isresult

      isinteriordiagonal_lg=.false.
      if (isinpoly_lg(i,j,npts,x,y,ipts,isccw,local_eps)) then
         x1 = x(ipts(i))
         y1 = y(ipts(i))
         x_leaf = x(ipts(i+1))
         y_leaf = y(ipts(i+1))
         t_lf = isleftoron_lg(x_leaf,y_leaf,x1,y1,x2,y2,isccw,local_eps)

c        print*, 'Leaf point on the left: ', t_lf

         x2 = x(ipts(j))
         y2 = y(ipts(j))
         dup_point = .false.
         point_on_same_side = .true.
         do it=j+1,npts
           x3 = x(ipts(it))
           y3 = y(ipts(it))
           dup_point = dup_point.or.
     *        issamepoint_lg(x2,y2,x3,y3,local_eps)

           if(.not.dup_point) then
              isresult=isleftoron_lg(x3,y3,x1,y1,x2,y2,isccw,local_eps)
              point_on_same_side = point_on_same_side.and.isresult
           endif
         enddo
         if(dup_point.and.(.not.point_on_same_side)) return
         if(isdiagonal_lg(i,j,npts,x,y,ipts,local_eps))
     *        isinteriordiagonal_lg=.true.
      endif
      return
      end

c function isdiagonal_lg
c  return true if the line from node i to node j is a diagonal
c  of the polygon.
      function isdiagonal_lg(i,j,npts,x,y,ipts,local_eps)
      implicit none
      logical isdiagonal_lg,isintersectortee_lg,issamepoint_lg
      logical test_pts1,test_pts2,test_pts3,test_pts4,cond
      integer i,j,npts,iv1,iv2,ipts(*),ipi,ipj,l
      real*8 x(*),y(*),local_eps

      ipi=ipts(i)
      ipj=ipts(j)
      isdiagonal_lg=.false.
c  look at all edges that do not have i or j as endpoints
c  and see if the diagonal ij intersects the edge
      do l=1,npts
         if(l.eq.npts) then
            iv1=ipts(l)
            iv2=ipts(1)
         else
            iv1=ipts(l)
            iv2=ipts(l+1)
         endif
         if(ipi.ne.iv1.and.ipi.ne.iv2.and.ipj.ne.iv1.and.ipj.ne.iv2)then
            if(isintersectortee_lg(x(iv1),y(iv1),x(iv2),y(iv2),
     *                 x(ipi),y(ipi),x(ipj),y(ipj),local_eps)) return
         endif
      enddo
      isdiagonal_lg=.true.
      return
      end

c function issamepoint_lg
c     check whether two points are the same
      function issamepoint_lg(x1,y1,x2,y2,local_eps)
      implicit none
      real*8 x1,x2,y1,y2,local_eps
      logical issamepoint_lg
      issamepoint_lg = .false.
      if ((ABS(x1-x2).lt.local_eps).and.
     *    (ABS(y1-y2).lt.local_eps))
     *   issamepoint_lg = .true.
      return
      end

