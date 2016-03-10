<%
    ui.decorateWith("appui", "standardEmrPage", [title: "Edit Bills"])
    ui.includeJavascript("billingui", "knockout-3.4.0.js")
    ui.includeJavascript("billingui", "moment.js")
%>
<script>
    var pData;
    jQuery(function () {
        jq("#waiverCommentDiv").hide();
        jq('#waiverAmount').on('change keyup paste', function () {
            var numb = jq('#waiverAmount').val();

            if (!isNaN(parseFloat(numb)) && isFinite(numb) && numb > 0) {
                jq("#waiverCommentDiv").show();
            }
            else {
                jq("#waiverCommentDiv").hide();
            }
        });
        pData = ${billingItems};
        var billItems = pData.billingItems;
        var bill = new BillItemsViewModel();
        jq('#surname').html(stringReplace('${patient.names.familyName}') + ',<em>surname</em>');
        jq('#othname').html(stringReplace('${patient.names.givenName}') + ' &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; <em>other names</em>');
        jq('#agename').html('${patient.age} years (' + moment('${patient.birthdate}').format('DD,MMM YYYY') + ')');

        jq('.tad').text('Last Visit: ' + moment('${previousVisit}').format('DD.MM.YYYY hh:mm') + ' HRS');


        // Class to represent a row in the bill addition grid
        function BillItem(initialBill) {
            var self = this;
            self.initialBill = ko.observable(initialBill);
            self.quantity = ko.observable(initialBill.quantity);
            self.price = ko.observable(initialBill.unitPrice);
            self.formattedPrice = ko.computed(function () {
                var price = self.price();
                return price ? price.toFixed(2) : "0.00";
            });

            self.itemTotal = ko.computed(function () {
                var price = self.price();
                var quantity = self.quantity();
                var runningTotal = price * quantity;
                return runningTotal ? runningTotal : "0.00";
            });
        }

        function BillItemsViewModel() {
            var self = this;

            // Editable data
            self.billItems = ko.observableArray([]);
            var mappedBillItems = jQuery.map(billItems, function (item) {
                return new BillItem(item)
            });
            self.billItems(mappedBillItems);

            // Computed data
            self.totalSurcharge = ko.computed(function () {
                var total = 0;
                for (var i = 0; i < self.billItems().length; i++)
                    total += self.billItems()[i].itemTotal();
                return total;
            });

            //observable waiver
            self.waiverAmount = ko.observable(0.00);

            //observable comment
            self.comment = ko.observable("");

            //observable waiver Number
            self.waiverNumber = ko.observable("");

            // Operations

            self.removeBillItem = function (item) {
                if(self.billItems().length > 1){
                    self.billItems.remove(item);
                }else{
                    jq().toastmessage('showNoticeToast', "A Bill Must have at least one item");
                }


            }
            self.cancelBillAddition = function () {
                window.location.replace("billableServiceBillListForBD.page?patientId=${patientId}&billId=${billId}")
            }
            self.submitBill = function () {
                jQuery("#action").val("submit");
                var waiverComment = jQuery("#waiverComment").val();
                if (self.totalSurcharge() < self.waiverAmount()) {
                    jq().toastmessage('showNoticeToast', "Please enter correct Waiver Amount");
                } else if (isNaN(self.waiverAmount()) || self.waiverAmount() < 0) {
                    jq().toastmessage('showNoticeToast', "Please enter correct Waiver Amount");
                } else if (waiverComment == '' || waiverComment == null) {
                    jq().toastmessage('showNoticeToast', "Please enter Comments/Waiver Number");

                } else {
                    //submit the details to the server
                    jq("#billsForm").submit();

                }
            }

            self.voidBill = function () {
                //set action to void
                jQuery("#action").val("void");
                jQuery("#billVoid").attr("class", "disabled");
                return 0;
            }
        }

        ko.applyBindings(bill, jq("#example")[0]);


    });//end of document ready



</script>

<style>
#breadcrumbs a, #breadcrumbs a:link, #breadcrumbs a:visited {
    text-decoration: none;
}

.new-patient-header .demographics .gender-age {
    font-size: 14px;
    margin-left: -55px;
    margin-top: 12px;
}

.new-patient-header .demographics .gender-age span {
    border-bottom: 1px none #ddd;
}

.new-patient-header .identifiers {
    margin-top: 5px;
}

.tag {
    padding: 2px 10px;
}

.tad {
    background: #666 none repeat scroll 0 0;
    border-radius: 1px;
    color: white;
    display: inline;
    font-size: 0.8em;
    margin-left: 4px;
    padding: 2px 10px;
}

.status-container {
    padding: 5px 10px 5px 5px;
}

.catg {
    color: #363463;
    margin: 35px 10px 0 0;
}

form input[type="text"] {
    background: transparent none repeat scroll 0 0;
}

form input[type="text"]:focus {
    outline: 1px none #ddd;
}

td a,
td a:hover {
    cursor: pointer;
    text-decoration: none;
}

.align-left {
    width: 200px;
    display: inline-block;
}

.align-right {
    float: right;
    width: 720px;
    display: inline-block;
}
</style>

<div class="clear"></div>

<div class="container">
    <div class="example">
        <ul id="breadcrumbs">
            <li>
                <a href="${ui.pageLink('referenceapplication', 'home')}">
                    <i class="icon-home small"></i></a>
            </li>
            <li>
                <i class="icon-chevron-right link"></i>
                <a href="${ui.pageLink('billingui', 'billingQueue')}">Billing</a>
            </li>

            <li>
                <i class="icon-chevron-right link"></i>
                <a href="${ui.pageLink('billingui', 'billingQueue')}">Service Bills</a>
            </li>

            <li>
                <i class="icon-chevron-right link"></i>
                Edit Bill(Bill ID: ${billId})
            </li>
        </ul>
    </div>

    <div class="patient-header new-patient-header">
        <div class="demographics">
            <h1 class="name">
                <span id="surname"></span>
                <span id="othname"></span>

                <span class="gender-age">
                    <span>
                        <% if (patient.gender == "F") { %>
                        Female
                        <% } else { %>
                        Male
                        <% } %>
                    </span>
                    <span id="agename"></span>

                </span>
            </h1>

            <br/>

            <div id="stacont" class="status-container">
                <span class="status active"></span>
                Visit Status
            </div>

            <div class="tag">Outpatient ${fileNumber}</div>

            <div class="tad">Last Visit</div>
        </div>

        <div class="identifiers">
            <em>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;Patient ID</em>
            <span>${patient.getPatientIdentifier()}</span>
            <br>

            <div class="catg">
                <i class="icon-tags small" style="font-size: 16px"></i><small>Category:</small> ${category}
            </div>
        </div>

        <div class="close"></div>
    </div>

    <div id="example">
        <div class="formfactor">
            <h2>Bill Items (<span data-bind="text: billItems().length"></span>)</h2>
        </div>
        <table>
            <thead>
            <tr>
                <th style="width: 40px; text-align: center;">#</th>
                <th>Service Name</th>
                <th style="width: 90px">Quantity</th>
                <th style="width:120px; text-align:right;">Unit Price</th>
                <th style="width:120px; text-align:right;">Item Total</th>
                <th style="width:20px; text-align:center;">&nbsp;</th>
            </tr>
            </thead>

            <tbody id="datafield" data-bind="foreach: billItems, visible: billItems().length > 0">
            <tr>
                <td style="text-align: center;"><span class="nombre"></span></td>
                <td data-bind="text: initialBill().service.name"></td>

                <td>
                    <input data-bind="value: quantity">
                </td>

                <td style="text-align: right;">
                    <span data-bind="text: formattedPrice"></span>
                </td>

                <td style="text-align: right;">
                    <span data-bind="text: itemTotal().toFixed(2)"></span>
                </td>

                <td style="text-align: center;">
                    <a class="remover" href="#" data-bind="click: \$root.removeBillItem">
                        <i class="icon-remove small" style="color:red"></i>
                    </a>
                </td>
            </tr>
            </tbody>

            <tbody>
            <tr style="border: 1px solid #ddd;">
                <td style="text-align: center;"></td>
                <td colspan="3"><b>Total Charge: Kshs</b></td>

                <td style="text-align: right;">
                    <span data-bind="text: totalSurcharge().toFixed(2)"></span>
                </td>
                <td style="text-align: right;"></td>
            </tr>

            <tr style="border: 1px solid #ddd;">
                <td style="text-align: center;"></td>
                <td colspan="3"><b>Waiver Amount: Kshs</b></td>

                <td style="text-align: right;">
                    <input id="waiverAmount" data-bind="value: waiverAmount"/>
                </td>
                <td style="text-align: right;"></td>
            </tr>
            </tbody>
        </table>

        <div id="waiverCommentDiv" style="padding-top: 10px;">
            <label for="waiverNumber" style="color: rgb(54, 52, 99);">Waiver Number</label>
            <input type="text" size="20&quot;" data-bind="value: waiverNumber" name="waiverNumber" id="waiverNumber"/>

        </div>
        <label for="waiverComment" style="color: rgb(54, 52, 99);">Comment</label>
        <textarea type="text" id="waiverComment" name="waiverComment" size="7" class="hasborder"
                  style="width: 99.4%; height: 60px;"
                  data-bind="value: comment"></textarea>

        <form method="post" id="billsForm" style="padding-top: 10px">
            <input id="patientId" type="hidden" value="${patientId}">
            <input id="action" name="action" type="hidden">
            <textarea name="bill" data-bind="value: ko.toJSON(\$root)" style="display:none;"></textarea>
            <button data-bind="click: submitBill, enable: billItems().length > 0 " class="confirm">Save Bill</button>
            <button id="billVoid" data-bind="click: voidBill" class="cancel">Void Bill</button>
            <button data-bind="click: cancelBillAddition" class="cancel">Cancel</button>

        </form>

    </div>
</div>



