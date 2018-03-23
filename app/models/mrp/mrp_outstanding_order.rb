class Mrp::MrpOutstandingOrder < ActiveRecord::Base
  # establish_connection "jdeoracle"
  # self.table_name = 'outstanding_orders'
  self.table_name = 'tmp_delete_outstanding'
  #cancel semua order dengan next status 525
  def self.copy_pr_to_x
    self.where("updated = false").each do |pr|
      JdeSoDetail.connection.execute("
        UPDATE PRODDTA.F41021 SET LIMCU = '     11001X' WHERE LILOTN LIKE '#{pr.lot}%'
      ")
      pr.update_attributes!(updated: true)
    end
  end

  def self.delete_outstanding_orders
    JdeSoDetail.connection.execute("
        UPDATE PRODDTA.F4211 so SET so.SDNXTR = '999', so.SDLTTR = '980', so.SDUORG = '0',
        so.SDSOQS = '0', so.SDSOBK = '0', so.SDSOCN = so.SDSQOR, so.SDCNDJ = '117365', so.SDRFRV = 'CBS'
        WHERE so.SDNXTR LIKE '540' AND so.SDMCU LIKE '%11001' AND REGEXP_LIKE(so.SDDCTO, 'ST')
        AND so.SDTRDJ < '117182'
      ")
  end

  #rubah status kode kit yang sudah mempunyai delivery number
  def self.kit_status_with_delivery_number
    JdeSoDetail.connection.execute("
        UPDATE PRODDTA.F4211 so SET so.SDNXTR = '999', so.SDLTTR = '580',
        so.SDSOQS = so.SDSQOR, so.SDRFRV = 'CBS'
        WHERE REGEXP_LIKE(so.SDNXTR, '540|560') AND REGEXP_LIKE(so.SDMCU, '11001') AND REGEXP_LIKE(so.SDDCTO, 'ST')
        AND so.SDKITDIRTY = '1' AND so.SDDELN > '1' AND so.SDTRDJ < '117182'
      ")
  end

  #rubah status kode kit yang tidak mempunyai delivery number
  def self.kit_status_without_delivery_number
    JdeSoDetail.connection.execute("
        UPDATE PRODDTA.F4211 so SET so.SDNXTR = '999', so.SDLTTR = '580',
        so.SDSOQS = so.SDSQOR, so.SDRFRV = 'CBS'
        WHERE REGEXP_LIKE(so.SDNXTR, '540|560') AND REGEXP_LIKE(so.SDMCU, '11001') AND REGEXP_LIKE(so.SDDCTO, 'ST')
        AND so.SDKITDIRTY = '1' AND so.SDDELN < '1' AND so.SDTRDJ < '117182'
      ")
  end

  def self.delete_outstanding_ppb_560
    ou_560 = JdeSoDetail.find_by_sql("
          SELECT SDITM, SDMCU, SDDOCO, SDSOQS, SDLOTN FROM PRODDTA.F4211
          WHERE SDNXTR LIKE '560' AND SDDCTO LIKE 'ST'
          AND SDMCU LIKE '%11001' AND SDTRDJ < '117182'
        ")
    ou_560.each do |ou|
      if ou.sdlotn.empty?
        JdeSoDetail.connection.execute("
          UPDATE PRODDTA.F41021 SET LIHCOM = LIHCOM - '#{ou.sdsoqs.to_i}'
          WHERE LIMCU LIKE '%#{ou.sdmcu.strip}' AND LIITM LIKE '#{ou.sditm.to_i}';
        ")
      else
        JdeSoDetail.connection.execute("
              UPDATE PRODDTA.F41021 SET LIHCOM = LIHCOM - '#{ou.sdsoqs.to_i}'
              WHERE LIMCU LIKE '%#{ou.sdmcu.strip}' AND LIITM LIKE '#{ou.sditm.to_i}' AND LILOTN = '#{ou.sdlotn}'
            ")
      end
    end
  end

  def self.cancel_wo
    self.all.each do |ou|
      JdeSoDetail.connection.execute("
        UPDATE PRODDTA.F4801 SET WASRST = '95'
        WHERE WADOCO = '#{ou.order_no}' AND WADCTO LIKE 'WO' AND WAMCU LIKE '%12002QT%'
      ")
    end
  end

  def self.delete_outstanding
    JdeSoDetail.connection.execute("
        UPDATE PRODDTA.F4211 SET SDNXTR = '999', SDLTTR = '980', SDUORG = '0',
        SDSOQS = '0', SDSOBK = '0', SDSOCN = SDSQOR, SDCNDJ = '117305', SDRFRV = 'CBS'
        WHERE SDNXTR LIKE '541' AND REGEXP_LIKE(SDDCTO, 'WR')
        AND SDTRDJ < '117305'
      ")
  end

  def self.trial_create_base_price
    a = BasePrice.find_by_sql("SELECT * FROM tmp_base_prices GROUP BY BPITM")
    a.each do |ae|
      statement = "INSERT /*+ IGNORE_ROW_ON_DUPKEY_INDEX(PRODDTA.F4106,(PRODDTA.F4106_PK) */ INTO
     PRODDTA.F4106 (BPITM, BPLITM, BPAITM, BPMCU, BPLOCN, BPLOTN,
      BPAN8, BPIGID, BPCGID, BPLOTG, BPFRMP, BPCRCD, BPUOM, BPEFTJ, BPEXDJ, BPUPRC, BPACRD, BPBSCD,
      BPLEDG, BPFVTR, BPFRMN, BPURCD, BPURDT, BPURAT, BPURAB, BPURRF, BPAPRS, BPUSER, BPPID, BPJOBN,
      BPUPMJ, BPTDAY) VALUES ('#{ae.BPITM}', '#{ae.BPLITM}', '#{ae.BPAITM}', '       11001',
      '                    ', '                              ', '0', '0', '0', '   ', '0', 'IDR', 'PC',
      '118001', '140366', '#{ae.BPUPRC}', '0', ' ', '  ', '0', '          ', '  ', '0', '0', '0', '               ',
      ' ', '2472AJI YU', 'JDE       ', 'JDE       ', '#{ae.BPUPMJ}', '9000')"
      cursor = JdeSoDetail.connection.execute(statement)
    end
  end

  def self.update_base_price
    a = BasePrice.find_by_sql("SELECT * FROM tmp_base_prices WHERE BPLITM LIKE 'KBR%' GROUP BY BPLITM")
    a.each do |ae|
      statement = "UPDATE PRODDTA.F4105 SET COUNCS = '#{ae.BPUPRC}', COTDAY = 9000, COUPMJ = '118001'
      WHERE COLITM LIKE '#{ae.BPLITM}%' AND
      COLEDG = '07' AND COMCU LIKE '%#{11002}'"
      JdeSoDetail.connection.execute(statement)
    end
  end

  def self.trial_create_order
    JdeSoDetail.connection.execute("
      INSERT INTO  CRPDTA.F4211 (SDKCOO, SDDOCO, SDDCTO, SDLNID, SDSFXO, SDMCU, SDCO, SDOKCO,
      SDOORN, SDOCTO, SDOGNO, SDRKCO, SDRORN, SDRCTO, SDRLLN, SDDMCT, SDDMCS, SDAN8,
      SDSHAN, SDPA8, SDDRQJ, SDTRDJ, SDPDDJ, SDADDJ, SDIVD, SDCNDJ, SDDGL, SDRSDJ, SDPEFJ,
      SDPPDJ, SDVR01, SDVR02, SDITM, SDLITM, SDAITM, SDLOCN, SDLOTN, SDFRGD, SDTHGD, SDFRMP,
      SDTHRP, SDEXDP, SDDSC1, SDDSC2, SDLNTY, SDNXTR, SDLTTR, SDEMCU, SDRLIT, SDKTLN, SDCPNT,
      SDRKIT, SDKTP, SDSRP1, SDSRP2, SDSRP3, SDSRP4, SDSRP5, SDPRP1, SDPRP2, SDPRP3, SDPRP4, SDPRP5,
      SDUOM, SDUORG, SDSOQS, SDSOBK, SDSOCN, SDSONE, SDUOPN, SDQTYT, SDQRLV, SDCOMM, SDOTQY, SDUPRC,
      SDAEXP, SDAOPN, SDPROV, SDTPC, SDAPUM, SDLPRC, SDUNCS, SDECST, SDCSTO, SDTCST, SDINMG, SDPTC,
      SDRYIN, SDDTBS, SDTRDC, SDFUN2, SDASN, SDPRGR, SDCLVL, SDCADC, SDKCO, SDDOC, SDDCT, SDODOC, SDODCT,
      SDOKC, SDPSN, SDDELN, SDTAX1, SDTXA1, SDEXR1, SDATXT, SDPRIO, SDRESL, SDBACK, SDSBAL, SDAPTS, SDLOB,
      SDEUSE, SDDTYS, SDNTR, SDVEND, SDCARS, SDMOT, SDROUT, SDSTOP, SDZON, SDCNID, SDFRTH, SDSHCM, SDSHCN,
      SDSERN, SDUOM1, SDPQOR, SDUOM2, SDSQOR, SDUOM4, SDITWT, SDWTUM, SDITVL, SDVLUM, SDRPRC, SDORPR, SDORP,
      SDCMGP, SDGLC, SDCTRY, SDFY, SDSO01, SDSO02, SDSO03, SDSO04, SDSO05, SDSO06, SDSO07, SDSO08, SDSO09,
      SDSO10, SDSO11, SDSO12, SDSO13, SDSO14, SDSO15, SDACOM, SDCMCG, SDRCD, SDGRWT, SDGWUM, SDSBL, SDSBLT,
      SDLCOD, SDUPC1, SDUPC2, SDUPC3, SDSWMS, SDUNCD, SDCRMD, SDCRCD, SDCRR, SDFPRC, SDFUP, SDFEA, SDFUC,
      SDFEC, SDURCD, SDURDT, SDURAT, SDURAB, SDURRF, SDTORG, SDUSER, SDPID, SDJOBN, SDUPMJ, SDTDAY, SDSO16,
      SDSO17, SDSO18, SDSO19, SDSO20, SDIR01, SDIR02, SDIR03, SDIR04, SDIR05, SDSOOR, SDVR03, SDDEID, SDPSIG,
      SDRLNU, SDPMDT, SDRLTM, SDRLDJ, SDDRQT, SDADTM, SDOPTT, SDPDTT, SDPSTM, SDXDCK, SDXPTY, SDDUAL, SDBSC,
      SDCBSC, SDCORD, SDDVAN, SDPEND, SDRFRV, SDMCLN, SDSHPN, SDRSDT, SDPRJM, SDOSEQ, SDMERL, SDHOLD, SDHDBU,
      SDDMBU, SDBCRC, SDODLN, SDOPDJ, SDXKCO, SDXORN, SDXCTO, SDXLLN, SDXSFX, SDPOE, SDPMTO, SDANBY, SDPMTN,
      SDNUMB, SDAAID, SDSPATTN, SDPRAN8, SDPRCIDLN, SDCCIDLN, SDSHCCIDLN, SDOPPID, SDOSTP, SDUKID, SDCATNM,
      SDALLOC, SDFULPID, SDALLSTS, SDOSCORE, SDOSCOREO, SDCMCO, SDKITID, SDKITAMTDOM, SDKITAMTFOR, SDKITDIRTY,
      SDOCITT, SDOCCARDNO, SDPMPN, SDPNS) VALUES (11000,2505,'SO',1000,0,11001,11000,'     ','        ',
      '  ',0,'     ','        ','  ',0,'            ',0,100100,100100,100100,114230,114230,114230,0,0,
      115164,0,114230,114230,114230,'01TEST                   ','                         ',10001,
      'DVE300040010492S200180   ','DVE30410492S200180       ','                    ',
      '                              ','   ','   ',0,0,0,'DV (E3) PARIS OSCAR BLACK     ',
      '200 X 180                     ','S ',525,520,11001,'        ',0,0,0,0,'E  ','DV ','E3 ','   ',
      '   ','   ','   ','   ','DH ','   ','PC',20000,0,0,20000,0,0,0,0,'S',' ',32000000000,0,0,0,' ',
      'PC',32000000000,0,0,0,0,'          ',45,' ',' ',0,0,'        ','ELITE   ','   ',0,'     ',0,'  ',0,
      '  ','     ',32671,0,'Y','          ','  ',' ',0,' ','Y','Y','Y','   ','   ','  ','  ',0,0,'   ','   ',
      '   ','   ','                    ','   ','   ','   ','                              ','PC',20000,'PC',
      20000,'PC',0,'LB',0,'GA','        ','        ',' ','  ','DVE ',20,14,' ',' ',' ',' ',' ',' ',' ',' ',
      ' ',' ',' ',' ',' ',' ',' ',' ','        ','   ',0,'  ','RET     ','X','  ','  ','  ','  ',' ',' ',' ',
      'IDR',0,0,0,0,0,0,'  ',0,0,0,'               ','1674DENI R','0257SITI F','EP4210    ','JDE       ',
      115333,155852,' ',' ',0,' ',' ','                              ','                              ',
      '                              ','                              ','                              ',0,
      '                         ',0,'                              ','          ',0,0,0,0,0,0,0,0,' ',0,' ',
      '          ','          ',1,0,' ','USR',0,0,0,0,0,'   ','  ','            ','            ','   ',0,
      114230,'     ',0,'  ',0,'   ','      ',' ',0,'            ',0,0,
      '                                                  ',0,0,0,0,0,'   ',0,'                              ',
      ' ',0,'                              ',0,' ',11000,1000,0,0,' ',' ',0,'                              ',0)
    ")
  end
end