<%@ Page Title="" Language="C#" MasterPageFile="~/master/master_main.master" AutoEventWireup="true" CodeFile="usermanage.aspx.cs" Inherits="group_usermanage" %>

<%@ Register TagPrefix="ubfgj3_uc" TagName="left_menu" Src="~/userControl/left_menu.ascx" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script>

        window.onload = function () {

            set_table_usermanage();

        }

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <div class="site-panel site-usermanage">
        <div class="site-layout-row">
            <ubfgj3_uc:left_menu ID="id_left_menu" runat="server" />
            <div class="site-content-main">
                <h1 class="site-page-title"><asp:Label ID="lblPageTitle" runat="server"></asp:Label></h1>
                <div class="site-usermanage-control-card">
                    <div class="site-filterbar">
                        <div>
                            <asp:DropDownList ID="ddl_retreat" runat="server" CssClass="ui-select" DataValueField="seq" DataTextField="retreat_name" AutoPostBack="true" OnSelectedIndexChanged="ddl_retreat_SelectedIndexChanged"></asp:DropDownList>
                        </div>
                        <div>
                            <asp:DropDownList ID="ddl_group" runat="server" CssClass="ui-select" DataValueField="seq" DataTextField="belong_nm" AutoPostBack="true" OnSelectedIndexChanged="ddl_group_SelectedIndexChanged"></asp:DropDownList>
                        </div>
                    </div>
                    <div class="site-help site-usermanage-help">
                        <ul>
                            <li>
                                <strong>자료저장 :</strong> <mark>[추가] → [정보입력] → [저장]</mark> ( 추가/삭제 후 반드시 '저장'을 해야만 반영됨 )
                            </li>
                            <li>
                                <strong>납부금액 : </strong>먼저 '이름' 등을 입력하여 저장하고, <mark>납부금액</mark>은 나중에 <mark>실제 납부 후 입력</mark> 할 것
                            </li>
                            <li>
                                <strong>삭제 :</strong> <mark>[행삭제] → [저장]</mark> ( 납부금액 저장 후 실무자 확인까지 처리된 경우는 삭제 안됨 )
                            </li>                        
                        </ul>
                        
                    </div>
                    <div id="divDuesInfo" runat="server" class="site-dues-info">
                    </div>
                </div>
                <div class="site-status-note site-usermanage-note">
                        <span class="badge bd-green-100">완전등록</span>
                        <span class="badge bd-yellow-100">부분등록</span>
                        <span class="badge bd-red-100">미등록</span>
                    <div style="padding-top:5px;">
                        <strong><small><span style="background-color:yellow;">'참석여부'</span><mark> 는 <span style="color:blue;">수양회 마지막날 이후, 실제 참석여부 확인 후!!</span> 선택하여 저장하세요!</mark></small></strong>
                    </div>
                    
                </div>
                <div class="site-table-scroll">
                    
                    <table id="tb_member" class="site-data-table site-data-table-sm">
                        <tr>
                            <th class='nowrap txt_center'>이름</th>                            
                            <th class='nowrap txt_center'>회원구분</th>
                            <th class='nowrap txt_center'>회비구분</th>
                            <th class='nowrap txt_center'>납부금액</th>
                            <th class='nowrap txt_center'>납부방법</th>
                            <th class='nowrap txt_center'>비고(메모)</th>
                            <th class='nowrap txt_center'>실무확인</th>
                            <th class='nowrap txt_center' style="color:yellow;">참석여부</th>
                            <th class='displaynone'></th>
                            <th class='nowrap txt_center'>삭제</th>
                        </tr>
                    </table> 
                </div>
                <div class="site-help site-help-compact site-usermanage-help site-usermanage-guide">
                    <ul>
                        <li>
                            <small>회원구분 : 리더 여부를 확인하기 위한 정보 ( 목자 / 목동 / 양 )</small>
                        </li>
                        <li>
                            <small>회비구분 : 납부할 금액을 확인하기 위한 정보</small>
                        </li>
                        <li>
                            <small>납부방법 : 납부한 방법 ( 계좌이체 / 현금납부 )</small>
                        </li>
                        <li>
                            <small><mark><strong>[요회담당자]</strong>는 최소한 <strong>'이름'</strong>, <strong>'회원구분'</strong>, <strong>'회비구분'</strong> 항목을 입력하셔야 합니다!!&nbsp;</mark></small>
                        </li>
                    </ul>
                </div>
                <div class="site-actions">
                    <button type="button" onclick="add_member_tr();" class="site-button site-button-secondary site-button-sm">추가</button>
                    <asp:Button ID="btnSave" runat="server" CssClass="site-button site-button-primary site-button-sm" Text="저장" OnClientClick="return save_members_table();" OnClick="btnSave_Click" />
                    <asp:Button ID="btnMig" runat="server" CssClass="site-button site-button-primary site-button-sm" Text="이전 수양회 구성원 이관" OnClientClick="return confirm_member_mig();" OnClick="btnMig_Click" />
                </div>
            </div>
        </div>
    </div>
    <asp:HiddenField ID="hdGroupMembersCount" runat="server" />
    <asp:HiddenField ID="hdGroupMembers" runat="server" />
    <asp:HiddenField ID="hdSaveMembersCount" runat="server" />
    <asp:HiddenField ID="hdSaveMembers" runat="server" />
    <asp:HiddenField ID="hdUsertypesCount" runat="server" />
    <asp:HiddenField ID="hdUsertypes" runat="server" />
    <asp:HiddenField ID="hdDuestypesCount" runat="server" />
    <asp:HiddenField ID="hdDuestypes" runat="server" />
    <asp:HiddenField ID="hdUserRole" runat="server" />
    <asp:HiddenField ID="hdBeforeRetreat" runat="server" />
    <asp:HiddenField ID="hdBeforeGroup" runat="server" />
    <asp:HiddenField ID="hdBeforeGroupNm" runat="server" />
    
</asp:Content>

