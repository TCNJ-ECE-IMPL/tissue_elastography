function echogui(action)
global rf env Data_file

ImSizeHndl=findobj(gcbf,'Tag','Image Size');
set(ImSizeHndl,'String',sprintf([Data_file '\n' num2str(size(rf,1)) ' x ',...
      num2str(size(rf,2)) ' DATA']))
% set(ImSizeHndl,'String',[Data_file ' ' num2str(size(rf,1)) ' x ',...
%       num2str(size(rf,2)) ' DATA'])

switch(action)
   case 'aline'
      AlineHndl=findobj(gcbf,'Tag','A line EdtTxt');
      Alineno=get(AlineHndl,'String');
      if isempty(Alineno)
         Alineno=num2str(fix(size(rf,2)/2));
         set(AlineHndl,'String',fix(size(rf,2)/2));
      end
      plot(rf(:,str2num(Alineno)));
      CbarHndl=findobj(gcbf,'Tag','C bar');
      set(CbarHndl,'Enable','off');
      AzHndl=findobj(gcbf,'Tag','Az EdtTxt');
      set(AzHndl,'Enable','off')
      ElHndl=findobj(gcbf,'Tag','El EdtTxt');
      set(ElHndl,'Enable','off')
   case 'aenv'
      AenvHndl=findobj(gcbf,'Tag','A line EdtTxt');
      Aenvno=get(AenvHndl,'String');
      if isempty(Aenvno)
         Aenvno=num2str(fix(size(env,2)/2));
         set(AenvHndl,'String',fix(size(env,2)/2));
      end
      plot(env(:,str2num(Aenvno)));
      CbarHndl=findobj(gcbf,'Tag','C bar');
      set(CbarHndl,'Enable','off');
      AzHndl=findobj(gcbf,'Tag','Az EdtTxt');
      set(AzHndl,'Enable','off')
      ElHndl=findobj(gcbf,'Tag','El EdtTxt');
      set(ElHndl,'Enable','off')
   case 'envelope'
      env=envelope(rf);
      % set(gcbf,'UserData',env)
      EimgHndl=findobj(gcbf,'Tag','G scale');
      set(EimgHndl,'Enable','on')
      MimgHndl=findobj(gcbf,'Tag','mesh env');
      set(MimgHndl,'Enable','on')
      AenvHndl=findobj(gcbf,'Tag','A env');
      set(AenvHndl,'Enable','on')
      LenvHndl=findobj(gcbf,'Tag','L env');
      set(LenvHndl,'Enable','on')
   case 'img_env'
      EnvmnHndl=findobj(gcbf,'Tag','EnvMn EdtTxt');
      imnE=get(EnvmnHndl,'String');
      if isempty(imnE)
         imnE=min(min(env));
         set(EnvmnHndl,'String',imnE);
      else
         imnE=str2num(imnE);
      end
      EnvmxHndl=findobj(gcbf,'Tag','EnvMx EdtTxt');
      imxE=get(EnvmxHndl,'String');
      if isempty(imxE)
         imxE=max(max(env));
         set(EnvmxHndl,'String',imxE);
      else
         imxE=str2num(imxE);
      end
      imagesc(env,[imnE imxE])
      CbarHndl=findobj(gcbf,'Tag','C bar');
      set(CbarHndl,'Enable','on');
      AzHndl=findobj(gcbf,'Tag','Az EdtTxt');
      set(AzHndl,'Enable','off')
      ElHndl=findobj(gcbf,'Tag','El EdtTxt');
      set(ElHndl,'Enable','off')
   case 'img_rf'
      RfmnHndl=findobj(gcbf,'Tag','RfMn EdtTxt');
      imnR=get(RfmnHndl,'String');
      if isempty(imnR)
         imnR=min(min(rf));
         set(RfmnHndl,'String',imnR);
      else
         imnR=str2num(imnR);
      end
      RfmxHndl=findobj(gcbf,'Tag','RfMx EdtTxt');
      imxR=get(RfmxHndl,'String');
      if isempty(imxR)
         imxR=max(max(rf));
         set(RfmxHndl,'String',imxR);
      else
         imxR=str2num(imxR);
      end
      imagesc(rf,[imnR imxR])
      CbarHndl=findobj(gcbf,'Tag','C bar');
      set(CbarHndl,'Enable','on');
      AzHndl=findobj(gcbf,'Tag','Az EdtTxt');
      set(AzHndl,'Enable','off')
      ElHndl=findobj(gcbf,'Tag','El EdtTxt');
      set(ElHndl,'Enable','off')
   case 'lline'
      LlineHndl=findobj(gcbf,'Tag','L line EdtTxt');
      Llineno=get(LlineHndl,'String');
      if isempty(Llineno)
         Llineno=num2str(fix(size(rf,1)/2));
         set(LlineHndl,'String',fix(size(rf,1)/2));
      end
      plot(rf(str2num(Llineno),:));
      CbarHndl=findobj(gcbf,'Tag','C bar');
      set(CbarHndl,'Enable','off');
      AzHndl=findobj(gcbf,'Tag','Az EdtTxt');
      set(AzHndl,'Enable','off')
      ElHndl=findobj(gcbf,'Tag','El EdtTxt');
      set(ElHndl,'Enable','off')
   case 'lenv'
      LenvHndl=findobj(gcbf,'Tag','L line EdtTxt');
      Lenvno=get(LenvHndl,'String');
      if isempty(Lenvno)
         Lenvno=num2str(fix(size(env,1)/2));
         set(LenvHndl,'String',fix(size(env,1)/2));
      end
      plot(env(str2num(Lenvno),:));
      CbarHndl=findobj(gcbf,'Tag','C bar');
      set(CbarHndl,'Enable','off');
      AzHndl=findobj(gcbf,'Tag','Az EdtTxt');
      set(AzHndl,'Enable','off')
      ElHndl=findobj(gcbf,'Tag','El EdtTxt');
      set(ElHndl,'Enable','off')
   case 'mesh_rf'
      AzHndl=findobj(gcbf,'Tag','Az EdtTxt');
      Az=get(AzHndl,'String');
      if isempty(Az)
         Az=num2str(-37.5);
         set(AzHndl,'String',-37.5);
      end
      ElHndl=findobj(gcbf,'Tag','El EdtTxt');
      El=get(ElHndl,'String');
      if isempty(El)
         El=num2str(30);
         set(ElHndl,'String',30);
      end
      Az=str2num(Az); El=str2num(El);
      mesh(rf)
      view([Az El]);
      CbarHndl=findobj(gcbf,'Tag','C bar');
      set(CbarHndl,'Enable','off');
      set(AzHndl,'Enable','on')
      set(ElHndl,'Enable','on')
   case 'mesh_env'
      AzHndl=findobj(gcbf,'Tag','Az EdtTxt');
      Az=get(AzHndl,'String');
      if isempty(Az)
         Az=num2str(-37.5);
         set(AzHndl,'String',-37.5);
      end
      ElHndl=findobj(gcbf,'Tag','El EdtTxt');
      El=get(ElHndl,'String');
      if isempty(El)
         El=num2str(30);
         set(ElHndl,'String',30);
      end
      Az=str2num(Az); El=str2num(El);
      mesh(env)
      view([Az El]);
      CbarHndl=findobj(gcbf,'Tag','C bar');
      set(CbarHndl,'Enable','off');
      set(AzHndl,'Enable','on')
      set(ElHndl,'Enable','on')
   case 'reset'
      AlineHndl=findobj(gcbf,'Tag','A line EdtTxt');
      set(AlineHndl,'String',fix(size(rf,2)/2));
      LlineHndl=findobj(gcbf,'Tag','L line EdtTxt');
      set(LlineHndl,'String',fix(size(rf,1)/2));
      RfmnHndl=findobj(gcbf,'Tag','RfMn EdtTxt');
      set(RfmnHndl,'String',min(min(rf)));
      RfmxHndl=findobj(gcbf,'Tag','RfMx EdtTxt');
      set(RfmxHndl,'String',max(max(rf)));
      AzHndl=findobj(gcbf,'Tag','Az EdtTxt');
      set(AzHndl,'String',-37.5);
      ElHndl=findobj(gcbf,'Tag','El EdtTxt');
      set(ElHndl,'String',30);
      if exist('env','var')
         EnvmnHndl=findobj(gcbf,'Tag','EnvMn EdtTxt');
         set(EnvmnHndl,'String',min(min(env)));
         EnvmxHndl=findobj(gcbf,'Tag','EnvMx EdtTxt');
         set(EnvmxHndl,'String',max(max(env)));
      end
   case 'close'
      close_op=questdlg('Really close figure?','Figure close query','Yes','No','No');
      if strcmpi(close_op,'yes'), close(gcf), end
   case 'open'
      open_op=questdlg('Proceed? All data will be erased!!','New file open query','Yes','No','No');
      if strcmpi(open_op,'yes')
          % close(gcf)  % closes current figure
          % rf=readeye(0);  % reads new file, and opens the new GUI
          % There was a problem with the new figure, it would be created on top of HDRGUI
          rf=readeye;  % reads new file
          cla
          % Clear display for all the editable text boxes
          ImSizeHndl=findobj(gcbf,'Tag','Image Size');
          set(ImSizeHndl,'String','');
          AlineHndl=findobj(gcbf,'Tag','A line EdtTxt');
          set(AlineHndl,'String','');
          AenvHndl=findobj(gcbf,'Tag','A line EdtTxt');
          set(AenvHndl,'String','');
          EnvmnHndl=findobj(gcbf,'Tag','EnvMn EdtTxt');
          set(EnvmnHndl,'String','');
          EnvmxHndl=findobj(gcbf,'Tag','EnvMx EdtTxt');
          set(EnvmxHndl,'String','');
          RfmnHndl=findobj(gcbf,'Tag','RfMn EdtTxt');
          set(RfmnHndl,'String','');
          RfmxHndl=findobj(gcbf,'Tag','RfMx EdtTxt');
          set(RfmxHndl,'String','');
          LlineHndl=findobj(gcbf,'Tag','L line EdtTxt');
          set(LlineHndl,'String','');
          LenvHndl=findobj(gcbf,'Tag','L line EdtTxt');
          set(LenvHndl,'String','');
          AzHndl=findobj(gcbf,'Tag','Az EdtTxt');
          set(AzHndl,'String','');
          ElHndl=findobj(gcbf,'Tag','El EdtTxt');
          set(ElHndl,'String','');
          % Enable 'off' for all the defaults
          CbarHndl=findobj(gcbf,'Tag','C bar');
          set(CbarHndl,'Enable','off');
          GsclHndl=findobj('Tag','G scale');
          set(GsclHndl,'Enable','off');
          AzHndl=findobj(gcbf,'Tag','Az EdtTxt');
          set(AzHndl,'Enable','off')
          ElHndl=findobj(gcbf,'Tag','El EdtTxt');
          set(ElHndl,'Enable','off')
          MenvHndl=findobj('Tag','mesh env');
          set(MenvHndl,'Enable','off');
          AenvHndl=findobj('Tag','A env');
          set(AenvHndl,'Enable','off');
          LenvHndl=findobj('Tag','L env');
          set(LenvHndl,'Enable','off');
      end
end