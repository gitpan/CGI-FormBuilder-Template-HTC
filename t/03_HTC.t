# $Id: 03_HTC.t,v 1.2 2006/11/22 19:13:12 tinita Exp $
use Test::More tests => 8;
use blib;
use CGI::FormBuilder;
BEGIN { use_ok('CGI::FormBuilder::Template::HTC') }
my $has_htc = 0;
eval "use HTML::Template::Compiled 0.82";
$has_htc = 1 if !$@;
SKIP: {
    skip "HTML::Template::Compiled >= 0.82 not installed", 1 unless $has_htc;
    my $template = <<'EOM';
JSHEAD:<%var form.jshead%>
FORMSTART:<tmpl_var form.start>
NAME:<tmpl_var form.field.name.field>
COLOR:<%= form.field.color.field %>
SIZE:<tmpl_var form.field.size.value>
SUBMIT:<tmpl_var form.submit>
FORMEND:<tmpl_var form.end>
EOM
    my $form = CGI::FormBuilder->new(
        action   => 'TEST',
        title    => 'TEST',
        fields    => [qw/name color email/],
        submit   => [qw/Update Delete/],
        reset    => 0,
        template => {
            scalarref => \$template,
            type => 'HTC',
            variable => 'form',
        },
        values   => { color => [qw/yellow green orange/] },
        validate => { color => [qw(red blue yellow pink)] },
    );
    my $mod = {
        color => {
            options => [[qw/red Red/],[qw/green Green/],[qw/ blue Blue/]],
            type => 'select',
        },
        size  => { value   => 42 }
    };
    while ( my ( $f, $o ) = each %{$mod} ) {
        $o->{name} = $f;
        $form->field(%$o);
    }
    my $out = $form->render;
    # print "out: $out\n";
    cmp_ok($out, '=~', qr{JSHEAD:.*function validate}s, "form jshead");
    cmp_ok($out, '=~', qr{FORMSTART:.*Generated by CGI::FormBuilder v$CGI::FormBuilder::VERSION.*action="TEST"}s, "form start");
    cmp_ok($out, '=~', qr{NAME:.*name="name"}s, "form name");
    cmp_ok($out, '=~', qr{COLOR:.*name="color".*red.*Red}s, "form color");
    cmp_ok($out, '=~', qr{SIZE:42}s, "form size");
    cmp_ok($out, '=~', qr{SUBMIT:.*name="_submit"}s, "form submit");
    cmp_ok($out, '=~', qr{FORMEND:</form>}s, "form end");

}
