   M S B A M L   `   `   `  ����D  @Test-CSOM, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null7 clr-namespace:Test_CSOM.ControlsTest_CSOM.Controls  5      /clr-namespace:Test_CSOM.ViewTest_CSOM.View  5      )    #Test_CSOM.Controls.ThreeColumnsGrid   5      W SPresentationCore, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35R NWindowsBase, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35\ XPresentationFramework, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35D 9http://schemas.microsoft.com/winfx/2006/xaml/presentation    5      R NSystem.Xaml, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089:x,http://schemas.microsoft.com/winfx/2006/xaml     5      Jmc;http://schemas.openxmlformats.org/markup-compatibility/2006     5      @d2http://schemas.microsoft.com/expression/blend/2008     5      2local clr-namespace:Test_CSOM.Controls     5      -viewclr-namespace:Test_CSOM.View     5      .��5      �   � ColumnDefinitions  5   
   �� 5      $	��100��6   �� 5      $	��100��6   �� 5      $	��100��6    � RowDefinitions 5   
   �� 5      $
��Auto �6   �� 5      $
��Auto �6   �� 5      $��3* �6   �� 5      $��* �6   .+�5   
   &    Test_CSOM.Controls.SendToControl  $��2��6   $��0��5      !   Test_CSOM.View.TaskListView  5   
   $��2��6   $��0��5      $��3��5       '   !Test_CSOM.Controls.SubjectControl  5!   
   $��2��6   $��1��5"      $   Test_CSOM.Controls.BodyControl  5#   
   $��2��6   $��2��6*   $��2��5$      +   %Test_CSOM.Controls.SendOutlookControl  5&   
   $��4��6#   $��0��5'   #   $��2��5(   #   (   "Test_CSOM.Controls.TransferDetails  5*   
   $��4��6    $��2��5+       5-      5.      